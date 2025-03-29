from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Reservation, Review, Vehicle, VehicleImage, User, db
from datetime import datetime
from sqlalchemy import desc

bp = Blueprint("reviews", __name__, url_prefix="/reviews")

@bp.route('/create', methods=['POST'])
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
    
    # Vérifier si l'utilisateur a déjà laissé un avis pour ce véhicule
    existing_review = Review.query.filter_by(user_id=user_id, vehicle_id=vehicle_id).first()
    if existing_review:
        return jsonify({"error": "You have already reviewed this vehicle"}), 400
    
    # Vérifier si l'utilisateur a réservé ce véhicule avant de laisser un avis
    reservation = Reservation.query.filter_by(user_id=user_id, vehicle_id=vehicle_id).first()
    if not reservation:
        return jsonify({"error": "You must rent a vehicle before reviewing it"}), 400
    
    # Créer l'avis
    review = Review(
        user_id=user_id,
        vehicle_id=vehicle_id,
        rating=rating,
        comment=comment,
        created_at=datetime.utcnow()
    )
    db.session.add(review)
    
    # Mettre à jour la note moyenne du véhicule
    db.session.flush()
    avg_rating = db.session.query(db.func.avg(Review.rating)).filter_by(vehicle_id=vehicle_id).scalar()
    vehicle.average_rating = round(float(avg_rating), 2) if avg_rating else None
    
    db.session.commit()
    
    return jsonify({
        "message": "Review added successfully",
        "review_id": review.id,
        "created_at": review.created_at
    }), 201

@bp.route('/vehicles/<int:vehicle_id>/reviews', methods=['GET'])
def get_vehicle_reviews(vehicle_id):
    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"error": "Vehicle not found"}), 404
    
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    reviews_query = Review.query.filter_by(vehicle_id=vehicle_id).order_by(desc(Review.created_at))
    pagination = reviews_query.paginate(page=page, per_page=per_page, error_out=False)
    
    results = []
    for r in pagination.items:
        user = User.query.get(r.user_id)
        results.append({
            "id": r.id,
            "user_id": r.user_id,
            "user_lname": user.nom if user else "Unknown lastName",
            "user_fname": user.prenom if user else "Unknown firstName",
            "rating": r.rating,
            "comment": r.comment,
            "created_at": r.created_at.isoformat()
        })
    
    # Calculer la moyenne des notes
    avg_rating = db.session.query(db.func.avg(Review.rating)).filter_by(vehicle_id=vehicle_id).scalar()
    total_reviews = reviews_query.count()
    
    return jsonify({
        "reviews": results,
        "total_reviews": total_reviews,
        "total_pages": pagination.pages,
        "current_page": page,
        "average_rating": round(float(avg_rating), 2) if avg_rating else None
    }), 200

@bp.route('/users/<int:user_id>/reviews', methods=['GET'])
@jwt_required()
def get_user_reviews(user_id):
    # Vérifier si l'utilisateur demande ses propres avis ou si c'est un admin
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if int(current_user_id) != int(user_id) and not user.is_admin:
        return jsonify({"error": "Unauthorized access"}), 403
    
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    reviews_query = Review.query.filter_by(user_id=user_id).order_by(desc(Review.created_at))
    pagination = reviews_query.paginate(page=page, per_page=per_page, error_out=False)
    
    results = []
    for r in pagination.items:
        vehicle = Vehicle.query.get(r.vehicle_id)
        results.append({
            "id": r.id,
            "vehicle_id": r.vehicle_id,
            "vehicle_name": vehicle.title if vehicle else "Unknown Vehicle",
            "user_lname": user.nom if user else "Unknown lastName",
            "user_fname": user.prenom if user else "Unknown firstName",
            "rating": r.rating,
            "comment": r.comment,
            "created_at": r.created_at.isoformat()
        })
    
    return jsonify({
        "reviews": results,
        "total_reviews": pagination.total,
        "total_pages": pagination.pages,
        "current_page": page
    }), 200

@bp.route('/update/<int:review_id>', methods=['PUT'])
@jwt_required()
def update_review(review_id):
    user_id = get_jwt_identity()
    review = Review.query.get(review_id)
    
    if not review:
        return jsonify({"error": "Review not found"}), 404
    
    if review.user_id != int(user_id):
        return jsonify({"error": "You can only update your own reviews"}), 403
    
    data = request.get_json()
    rating = data.get("rating")
    comment = data.get("comment")
    
    if rating and not (1 <= rating <= 5):
        return jsonify({"error": "Rating must be between 1 and 5"}), 400
    
    if rating:
        review.rating = rating
    if comment:
        review.comment = comment
    
    review.updated_at = datetime.utcnow()
    
    # Mettre à jour la note moyenne du véhicule
    db.session.flush()
    avg_rating = db.session.query(db.func.avg(Review.rating)).filter_by(vehicle_id=review.vehicle_id).scalar()
    vehicle = Vehicle.query.get(review.vehicle_id)
    if vehicle:
        vehicle.average_rating = round(float(avg_rating), 2) if avg_rating else None
    
    db.session.commit()
    
    return jsonify({"message": "Review updated successfully"}), 200

@bp.route('/delete/<int:review_id>', methods=['DELETE'])
@jwt_required()
def delete_review(review_id):
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    review = Review.query.get(review_id)
    
    if not review:
        return jsonify({"error": "Review not found"}), 404
    
    if review.user_id != int(user_id) and not user.is_admin:
        return jsonify({"error": "Unauthorized action"}), 403
    
    vehicle_id = review.vehicle_id
    db.session.delete(review)
    
    # Mettre à jour la note moyenne du véhicule
    db.session.flush()
    avg_rating = db.session.query(db.func.avg(Review.rating)).filter_by(vehicle_id=vehicle_id).scalar()
    vehicle = Vehicle.query.get(vehicle_id)
    if vehicle:
        vehicle.average_rating = round(float(avg_rating), 2) if avg_rating else None
    
    db.session.commit()
    
    return jsonify({"message": "Review deleted successfully"}), 200