from flask import Blueprint, request, jsonify, url_for
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Payment, Reservation, Vehicle, VehicleImage, User, db

import os
from werkzeug.utils import secure_filename
from flask import   current_app

import json
import stripe



bp = Blueprint("payments", __name__, url_prefix="/payments")

@bp.route("/create-session", methods=["POST"])
@jwt_required()
def create_payment_session():

    print("Creating payment session...")
    user_id = int(get_jwt_identity())
    data = request.get_json()
    print(f"Received data: {data}")
    reservation_id = data.get("reservation_id")
    amount = data.get("amount")

    # Vérifiez la réservation
    reservation = Reservation.query.get(reservation_id)
    if not reservation or reservation.user_id != user_id:
        return jsonify({"message": "Invalid reservation"}), 400

    # Créez une session Stripe
    session = stripe.checkout.Session.create(
        payment_method_types=["card"],
        line_items=[{
            "price_data": {
                "currency": "eur",
                "product_data": {"name": f"Reservation {reservation_id}"},
                "unit_amount": int(amount * 100),  # Stripe utilise des centimes
            },
            "quantity": 1,
        }],
        mode="payment",
        success_url=url_for("payment.success", _external=True),
        cancel_url=url_for("payment.cancel", _external=True),
        metadata={
            "reservation_id": reservation_id,
            "user_id": user_id
        }
    )
    return jsonify({"checkout_url": session.url}), 200


@bp.route('/success', methods=['GET'])
def success():
    return "Payment successful", 200

@bp.route('/cancel', methods=['GET'])
def cancel():
    return "Payment canceled", 200



@bp.route('/webhook', methods=['POST'])
def webhook():
    endpoint_secret = current_app.config["STRIPE_WEBHOOK_SECRET"]
    event = None
    payload = request.data

    try:
        event = json.loads(payload)
    except json.decoder.JSONDecodeError as e:
        print('⚠️  Webhook error while parsing basic request.' + str(e))
        return jsonify(success=False)
    if endpoint_secret:
        # Only verify the event if there is an endpoint secret defined
        # Otherwise use the basic event deserialized with json
        sig_header = request.headers.get('stripe-signature')
        try:
            event = stripe.Webhook.construct_event(
                payload, sig_header, endpoint_secret
            )
        except stripe.error.SignatureVerificationError as e:
            print('⚠️  Webhook signature verification failed.' + str(e))
            return jsonify(success=False)

   
    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]

        print(f"Session completed: {session}")

        # Récupérer les détails de la session
        reservation_id = session["metadata"]["reservation_id"]
        user_id = session["metadata"]["user_id"]
        amount = session["amount_total"] / 100  # Convertir en euros

        reservation = Reservation.query.filter_by(id=reservation_id).first()
        vehicleId = int(reservation.vehicle_id)
        vehicle = Vehicle.query.filter_by(id=vehicleId).first()

        # Enregistrer le paiement dans la base de données
        payment = Payment(
            reservation_id=reservation_id,
            user_id=user_id,
            amount=amount,
            status="succeeded"
        )

        reservation.status = "CONFIRMER"
        vehicle.available = False
        
        db.session.add(payment)
        db.session.commit()

        

        print(f"Payment recorded for reservation {reservation_id} by user {user_id}")

    return jsonify({"message": "Webhook received"}), 200