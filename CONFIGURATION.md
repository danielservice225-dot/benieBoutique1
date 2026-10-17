# Configuration de Bénie Boutique

## 1. Publier le site avec GitHub Pages

Dépôt : https://github.com/danielservice225-dot/benieBoutique1

Dans GitHub :
1. Ouvrez **Settings → Pages**.
2. Dans **Build and deployment**, choisissez **Deploy from a branch**.
3. Branche : **main** ; dossier : **/(root)** ; cliquez **Save**.
4. Attendez le déploiement dans **Actions** (workflow Pages) et ouvrez :
   https://danielservice225-dot.github.io/benieBoutique1/

Les fichiers `index.html` et `admin.html` doivent rester à la racine du dépôt. Un commit GitHub ne garantit pas que Pages est activé.

## 2. Vider le faux catalogue et configurer les permissions Supabase

Le site n'utilise plus les articles de démonstration codés en HTML. Il affiche uniquement les produits enregistrés dans Supabase.

1. Ouvrez le projet Supabase : https://supabase.com/dashboard/project/arodkdazldfvyiecjstk
2. Allez dans **SQL Editor → New query**.
3. Ouvrez le fichier `supabase/setup.sql` dans ce dépôt, copiez tout son contenu dans SQL Editor, puis cliquez **Run**.
4. Ce script crée les tables et politiques de sécurité attendues et supprime les anciennes lignes de produits de démonstration. Il conserve les commandes.
5. Allez dans **Authentication → Users**. Créez un utilisateur avec votre e-mail et un mot de passe, ou sélectionnez votre utilisateur existant. Copiez son **UUID**.
6. Dans SQL Editor, exécutez cette commande en remplaçant les deux valeurs :
   ```sql
   insert into public.sellers(user_id,email,active)
   values ('UUID-DE-L-UTILISATEUR', 'votre-email@example.com', true)
   on conflict (user_id) do update
   set email=excluded.email, active=true;
   ```
7. Connectez-vous à l'espace vendeur avec exactement cet e-mail et ce mot de passe :
   https://danielservice225-dot.github.io/benieBoutique1/admin.html

Le compte doit exister dans **Authentication → Users** ET dans la table `public.sellers`. Sans cela, la connexion ou les opérations d'ajout/modification/suppression ne fonctionneront pas.

## 3. Ajouter vos vrais articles

Dans l'administration, cliquez **Ajouter un produit** :
- saisissez le nom et le prix réel en FCFA ;
- choisissez la catégorie (vêtement, Arduino, ESP32, Raspberry Pi, kits, composants) ;
- choisissez une vraie photo depuis votre appareil ou collez une URL HTTPS publique ;
- indiquez le stock et la description, puis **Enregistrer le produit**.

Les produits enregistrés sont visibles sur le site public. Les photos importées sont compressées puis enregistrées avec la fiche produit. Pour éviter des données trop lourdes, les images sont limitées après compression.

## Sécurité

- Ne placez jamais la clé Supabase `service_role` ou une clé secrète dans `index.html` ou `admin.html`.
- Le script utilise des politiques RLS : lecture publique des produits, écriture des produits réservée aux comptes inscrits dans `public.sellers`, commandes accessibles au vendeur.
- La clé publique/publishable dans le HTML n'est pas un mot de passe ; la sécurité dépend des politiques RLS.
