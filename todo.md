# 🛠️ Plan Initial et État Actuel de CarOnePlus
**Voici une vue d'ensemble de votre plan initial avec les fonctionnalités et leur état d'avancement.**

## 🛠️ Fonctionnalités Principales
### 1. Gestion des Comptes Utilisateurs (Authentification et Profils)
#### Inscription d'utilisateurs : ✅
 - Hachage des mots de passe.
 - Vérification des doublons d'e-mail.
#### Connexion avec JWT : ✅
 - Authentification avec retour d’un token JWT.
#### Gestion du Profil : 🟡 En cours
 - Modifier les informations personnelles (nom, e-mail, mot de passe).
 - Téléchargement et gestion des documents (comme le permis de conduire).
### 2. Catalogue des Véhicules
#### Ajout et Gestion des Véhicules (Propriétaires) : ✅
 - Ajout de véhicules avec titre, description, prix, localisation, et disponibilité.
 - Téléchargement d'images pour un véhicule.
#### Recherche et Filtrage des Véhicules (Locataires) : ✅
 - Filtres : localisation, prix, disponibilité.
 - Tri par distance, prix croissant/décroissant ou avis (non implémenté).
### 3. Réservation des Véhicules
#### Créer une Réservation : 🟥 Non implémenté
 - Réserver un véhicule pour une période donnée.
 - Vérification de la disponibilité avant réservation.
#### Gestion des Statuts de Réservation : 🟥 Non implémenté
 - Statuts : en attente, confirmée, en cours, terminée, annulée.
#### Historique des Réservations : 🟥 Non implémenté
 - Voir les réservations passées, actuelles et futures.
### 4. Paiement Sécurisé
#### Intégration d’une API de paiement (Stripe/PayPal) : 🟥 Non implémenté
 - Paiement sécurisé pour valider une réservation.
 - Blocage et libération des cautions.
### 5. Géolocalisation des Véhicules
#### Suivi GPS des Véhicules : 🟥 Non implémenté
 - Intégration de Google Maps API.
 - Alertes pour les propriétaires en cas de sortie de zone autorisée.
#### Recherche Géographique : 🟥 Non implémenté
 - Recherche de véhicules autour d'une localisation spécifique.
### 6. Notifications
#### Notifications Push : 🟥 Non implémenté
 - Rappels de début et fin de location.
 - Alertes pour les propriétaires (nouvelle réservation, annulation).
### 7. Gestion des Avis et Notes
#### Évaluations : 🟥 Non implémenté
 - Les locataires évaluent les véhicules et propriétaires.
 - Les propriétaires évaluent les locataires.
#### Système de Moyenne des Notes : 🟥 Non implémenté
 - Afficher la moyenne des notes pour chaque véhicule.
### 8. Sécurité et Support
#### Signalement des Incidents : 🟥 Non implémenté
 - Endpoint pour signaler des problèmes (pannes, accidents).
#### Support Client : 🟥 Non implémenté
 - Endpoint pour contacter le support.
#### Assurance Véhicule : 🟥 Non implémenté
 - Option d’ajouter une assurance pour chaque réservation.


## 📋 Plan de Développement : État Actuel**
**Étape 1 : Authentification et Gestion des Utilisateurs**
- ✅ Inscription et connexion avec JWT.
- 🟡 Gestion des profils utilisateurs (reste à compléter).
**Étape 2 : Gestion des Véhicules**
- ✅ Création, modification, et suppression des véhicules (CRUD).
- ✅ Upload des images.
- 🟡 Recherche et tri avancés (reste le tri).
**Étape 3 : Réservation des Véhicules**
- 🟥 Création de réservations et gestion des statuts.
**Étape 4 : Paiement Sécurisé**
- 🟥 Intégration d’une API de paiement.
**Étape 5 : Notifications et Géolocalisation**
- 🟥 Notifications push avec Firebase.
- 🟥 Intégration de Google Maps API.
**Étape 6 : Système de Notes et Avis**
- 🟥 Ajout des fonctionnalités d'évaluation.