from app import db
from flask_bcrypt import Bcrypt

bcrypt = Bcrypt()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    prenom = db.Column(db.String(120),unique=False, nullable=True)
    nom = db.Column(db.String(120),unique=False, nullable=True)
    telephone = db.Column(db.String(15), unique=True, nullable=True)
    role = db.Column(db.String(20), nullable=False, default="locateur")  # Ajout du rôle
    password = db.Column(db.String(128), nullable=False)
    is_active = db.Column(db.Boolean, default=False)  # ✅ Nouveau champ
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    def set_password(self, password):
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)


class UserImage(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    file_name = db.Column(db.String(200), nullable=False)
    file_path = db.Column(db.String(300), nullable=False)
    uploaded_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('user-images', cascade='all, delete-orphan'))


class RevokedToken(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), unique=True, nullable=False)

    @classmethod
    def is_token_revoked(cls, jti):
        return cls.query.filter_by(jti=jti).first() is not None


class PasswordResetCode(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    code = db.Column(db.String(6), nullable=False) 
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('reset_codes', cascade='all, delete-orphan'))

   
class Vehicle(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price_per_day = db.Column(db.Float, nullable=False)
    type_de_vehicule = db.Column(db.String(100), nullable=True)
    type_de_carburant = db.Column(db.String(100), nullable=True)
    localisation = db.Column(db.String(100), nullable=False) # addresse textuelle
    puissance = db.Column(db.String(15), nullable=True) 
    available = db.Column(db.Boolean, default=True)
    lat = db.Column(db.Float, nullable=True)  # Latitude
    lng = db.Column(db.Float, nullable=True)  # Longitude
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    owner = db.relationship('User', backref=db.backref('vehicles', cascade='all, delete-orphan'))
    images = db.relationship('VehicleImage', backref='vehicle', cascade='all, delete-orphan', lazy=True)


class VehicleImage(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicle.id', ondelete='CASCADE'), nullable=False)
    file_name = db.Column(db.String(200), nullable=False, unique= True)
    file_path = db.Column(db.String(500), nullable=False)
    uploaded_at = db.Column(db.DateTime, server_default=db.func.now())

    #vehicle = db.relationship('Vehicle', backref=db.backref('vehicule_images', cascade='all, delete-orphan'))

class Reservation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicle.id', ondelete='CASCADE'), nullable=False)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    status = db.Column(db.String(20), default="pending")  # Statuts : pending, confirmed, in_progress, completed, cancelled
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('user-reservations', cascade='all, delete-orphan'))
    vehicle = db.relationship('Vehicle', backref=db.backref('vehicules-reservations', cascade='all, delete-orphan'))

class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reservation_id = db.Column(db.Integer, db.ForeignKey('reservation.id', ondelete='CASCADE'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(50), nullable=False)  # Ex: succeeded, pending, failed
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    reservation = db.relationship('Reservation', backref=db.backref('Reservation-payments', cascade='all, delete-orphan'))
    user = db.relationship('User', backref=db.backref('user-payments', cascade='all, delete-orphan'))


class Review(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    vehicle_id = db.Column(db.Integer, db.ForeignKey('vehicle.id', ondelete='CASCADE'), nullable=False)
    rating = db.Column(db.Float, nullable=False)  # Note entre 1 et 5
    comment = db.Column(db.Text, nullable=True)  # Commentaire facultatif
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('user-reviews', cascade='all, delete-orphan'))
    vehicle = db.relationship('Vehicle', backref=db.backref('vehicule-reviews', cascade='all, delete-orphan'))


class Incident(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reservation_id = db.Column(db.Integer, db.ForeignKey('reservation.id', ondelete='CASCADE'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    description = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default="pending")  # Statuts : pending, resolved, closed
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('user-incidents', cascade='all, delete-orphan'))
    reservation = db.relationship('Reservation', backref=db.backref('reservation-incidents', cascade='all, delete-orphan'))


class SupportRequest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    subject = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default="pending")  # Statuts : pending, resolved, closed
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    user = db.relationship('User', backref=db.backref('user-support_requests', cascade='all, delete-orphan'))


class Insurance(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    reservation_id = db.Column(db.Integer, db.ForeignKey('reservation.id', ondelete='CASCADE'), nullable=False)
    type = db.Column(db.String(50), nullable=False)  # Exemple : basic, premium
    cost = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    reservation = db.relationship('Reservation', backref=db.backref('Reservation-insurance', cascade='all, delete-orphan'))

