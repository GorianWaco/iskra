# Iskra — przywrócenie na nowym systemie

Program, modele i pamięć zostają na dysku SSD z etykietą **Iskra**. Tego dysku nie formatuj. W tym repozytorium jest tylko skrypt, który wpina Iskrę w świeży CachyOS albo Arch.

## Po instalacji systemu

Podłącz dysk Iskra, zaloguj się i wklej:

```bash
curl -fsSL https://raw.githubusercontent.com/GorianWaco/iskra/main/przywroc.sh | bash
```

Skrypt szuka dysku po etykiecie `Iskra`, a gdy jej nie ma — po UUID. Potem odpala `install.sh` z dysku. Ten instalator dokłada paczki GTK, skrót `iskra`, pozycję w menu, wtyczkę GNOME i wpis `/mnt/iskra` w `/etc/fstab`.

Start: menu → **Iskra**, albo w terminalu `iskra`.

Zjazd okna z panelu ładuje się po jednym wylogowaniu.

## Na dysku, bez GitHuba

Gdy dysk jest już otwarty w Plikach, wystarczy dwuklik `2-Zainstaluj-Iskre`.
