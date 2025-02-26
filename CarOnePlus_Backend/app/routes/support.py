from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import SupportRequest, db

bp = Blueprint("support", __name__, url_prefix="/support")

@bp.route("/contact", methods=["POST"])
@jwt_required()
def contact_support():
    user_id = get_jwt_identity()
    data = request.get_json()
    subject = data.get("subject")
    message = data.get("message")

    if not subject or not message:
        return jsonify({"error": "Subject and message are required"}), 400

    # Créer une requête de support
    support_request = SupportRequest(
        user_id=user_id,
        subject=subject,
        message=message
    )
    db.session.add(support_request)
    db.session.commit()

    return jsonify({"message": "Support request submitted successfully", "request_id": support_request.id}), 201

@bp.route("/requests", methods=["GET"])
@jwt_required()
def list_support_requests():
    user_id = get_jwt_identity()
    requests = SupportRequest.query.filter_by(user_id=user_id).all()

    results = [
        {
            "id": r.id,
            "subject": r.subject,
            "message": r.message,
            "status": r.status,
            "created_at": r.created_at
        }
        for r in requests
    ]
    return jsonify(results), 200
