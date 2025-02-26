from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Reservation, Review, Vehicle, VehicleImage, User, db

bp = Blueprint("reviews", __name__, url_prefix="/reviews")

@bp.route('/create_reviews', methods=['POST'])
@jwt_required()
def add_review():
    user_id = get_jwt_identity()
    data = request.get_json()

    vehicle_id = data.get("vehicle_id")
    rating = data.get("rating")
    comment = data.get("comment")

    # Vérifications
    if not (1 <= rating <= 5):
        return jsonify({"error": "Rating must be between 1 and 5"}), 400

    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"error": "Vehicle not found"}), 404

    # Créer l'avis
    review = Review(
        user_id=user_id,
        vehicle_id=vehicle_id,
        rating=rating,
        comment=comment
    )
    db.session.add(review)
    db.session.commit()

    return jsonify({"message": "Review added successfully"}), 201


@bp.route('/vehicles/<int:vehicle_id>/reviews', methods=['GET'])
def get_reviews(vehicle_id):
    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"error": "Vehicle not found"}), 404

    reviews = Review.query.filter_by(vehicle_id=vehicle_id).all()
    results = [
        {
            "user_id": r.user_id,
            "rating": r.rating,
            "comment": r.comment,
            "created_at": r.created_at
        } for r in reviews
    ]

    # Calculer la moyenne des notes
    avg_rating = db.session.query(db.func.avg(Review.rating)).filter_by(vehicle_id=vehicle_id).scalar()

    return jsonify({
        "reviews": results,
        "average_rating": round(avg_rating, 2) if avg_rating else None
    }), 200


@bp.route('/users/<int:user_id>/reviews', methods=['GET'])
@jwt_required()
def get_user_reviews(user_id):
    reviews = Review.query.filter_by(user_id=user_id).all()
    results = [
        {
            "vehicle_id": r.vehicle_id,
            "rating": r.rating,
            "comment": r.comment,
            "created_at": r.created_at
        } for r in reviews
    ]
    return jsonify(results), 200

