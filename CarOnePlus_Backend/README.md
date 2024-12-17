# Création de la Base de Données et de l'Utilisateur
## Ouvrez PostgreSQL dans le terminal via psql :

```bash
psql -U postgres
Exécutez les commandes SQL suivantes :

-- Créer la base de données
CREATE DATABASE caroneplus;

-- Créer un utilisateur avec mot de passe
CREATE USER caroneuser WITH PASSWORD 'securepassword';

-- Donner des privilèges à l'utilisateur
GRANT ALL PRIVILEGES ON DATABASE caroneplus TO caroneuser;

\c car_one_plus  -- Se connecter à la base de données
GRANT ALL ON SCHEMA public TO caroneplus_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO caroneplus_user;

-- Quitter psql
\q 
```
# Configuration de Flask pour PostgreSQL
## Variables d'Environnement


### Créez un fichier .env à la racine du projet :
SECRET_KEY=your_secret_key
JWT_SECRET_KEY=your_jwt_secret_key
DATABASE_URL=postgresql://caroneuser:securepassword@localhost/caroneplus

## Configuration dans Flask
Dans le fichier app/config.py, configurez SQLAlchemy pour PostgreSQL :
```python
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev")
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", "postgresql://caroneuser:securepassword@localhost/caroneplus"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret")
🔨 Commandes pour Initialiser et Gérer la Base de Données
```

## Initialiser les migrations :

```bash
flask db init
Créer une migration pour appliquer le modèle User :
bash
flask db migrate -m "Initial migration - Add User model"
Appliquer les migrations à la base PostgreSQL :
flask db upgrade
```

## 🚀 Lancer le Serveur Flask
### Étapes pour démarrer le projet :
#### Activer l'environnement virtuel :
```bash
source env/bin/activate       # Linux/Mac
env\Scripts\activate          # Windows
Installer les dépendances :
bash
pip install -r requirements.txt
Démarrer le serveur :
bash
python run.py
```
## Le serveur est accessible à l'adresse suivante :
http://127.0.0.1:5000

## Endpoint de Test
Pour vérifier la connexion à la base de données PostgreSQL, utilisez l'endpoint suivant :

** GET /auth/test-db **
Réponse attendue si aucun utilisateur n'existe :
json

{
    "message": "Database connected! No users found."
}