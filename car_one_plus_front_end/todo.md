# TODO: Frontend (Flutter)

## Modules Déjà Configurés :
- [✔️] **Configuration de l’environnement Flutter**
  - Flutter installé, avec Android Studio comme IDE principal.
  - Intégration de dépendances principales :
    - `http`, `provider`, `google_fonts`, `flutter_local_notifications`, etc.
  - Test de connexion backend (login et gestion des données).

## Plan de Développement Frontend :

### [⚙️ En cours] Authentification
- Créer l'interface utilisateur pour l'inscription et la connexion.
- Gestion des erreurs :
  - Validation des champs.
  - Gestion des retours backend.

### [🔲] Catalogue des Véhicules
- Affichage des véhicules disponibles : liste avec images et détails.
- Ajout de filtres (prix, type, localisation).

### [🔲] Réservations
- Interface pour réserver un véhicule.
- Historique des réservations (avec statut).

### [🔲] Paiement
- Intégration de Stripe avec Flutter pour gérer les paiements.
- Gestion des erreurs de paiement.

### [🔲] Géolocalisation
- Intégration de Google Maps pour afficher les véhicules.
- Recherche de véhicules proches de l’utilisateur.

### [🔲] Notifications
- Intégration de Firebase Cloud Messaging pour envoyer des notifications push.

### [🔲] Avis et Notes
- Interface pour laisser des avis et notes sur les véhicules.
- Affichage des avis d’autres utilisateurs.

### [🔲] Sécurité et Support
- Formulaire de contact intégré.
- Signalement d’incidents via l'application.
