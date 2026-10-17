-- Bénie Boutique : supprimer uniquement les 23 anciens articles fictifs.
-- Supabase > SQL Editor > New query > coller ce fichier > Run.
-- Cette requête ne supprime ni les commandes, ni les autres produits.

delete from public.products
where lower(trim(coalesce(data->>'name', ''))) in (
  'robe wax évasée',
  'ensemble pagne 2 pièces',
  'pantalon palazzo',
  'chemise lin manches longues',
  't-shirt coton col rond',
  'sneakers blanches',
  'robe wax fillette',
  'ensemble short et t-shirt',
  'sneakers enfant',
  'arduino starter kit',
  'arduino uno r3',
  'arduino nano ch340',
  'kit débutant led et résistances',
  'kit 37 capteurs',
  'raspberry pi 4 model b 4 go',
  'raspberry pi zero 2 w',
  'boîtier pi 4 avec ventilateur',
  'esp32 devkit v1',
  'esp32-cam',
  'esp32 avec écran oled 0,96"',
  'capteur dht22',
  'module relais 2 canaux 5v',
  'breadboard 830 points'
);
