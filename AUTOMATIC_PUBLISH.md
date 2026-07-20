# Automatisch publiceren naar GitHub

Voor het publiceren zijn twee bestanden toegevoegd:

- `PUBLISH_TO_GITHUB.cmd` - gemakkelijk starten door erop te dubbelklikken.
- `publish-to-github.ps1` - het PowerShell-script dat de stappen uitvoert.

## Eerste keer publiceren

1. Dubbelklik op `PUBLISH_TO_GITHUB.cmd`.
2. Controleer de getoonde repository en typ `Y`.
3. Als de GitHub-login nodig of verlopen is, opent GitHub CLI eenmalig de browser.
4. Meld je aan bij het juiste GitHub-account en geef GitHub CLI toestemming.
5. Het script gaat daarna automatisch verder.

Het script:

1. controleert Git en GitHub CLI;
2. maakt lokaal een Git-repository aan als die nog niet bestaat;
3. commit alle bestanden in de map `Doosan-Modules`;
4. maakt `ZwartIndustrial/Doosan-Modules` aan als die nog niet bestaat;
5. pusht de huidige branch zonder ooit een force-push uit te voeren;
6. maakt de release `plcdata-v0.0.1` met de module, PDF-handleiding en SHA-256-controlefile;
7. opent de gepubliceerde repository in de browser.

## Later opnieuw uitvoeren

Je kunt hetzelfde CMD-bestand opnieuw starten nadat documentatie of modules zijn gewijzigd. Nieuwe wijzigingen worden gecommit en gepusht. Een reeds bestaande release wordt voor de veiligheid niet automatisch overschreven.

## Optionele PowerShell-parameters

Geavanceerd gebruik vanuit PowerShell:

```powershell
.\publish-to-github.ps1 -Yes
.\publish-to-github.ps1 -SkipRelease
.\publish-to-github.ps1 -NoBrowser
.\publish-to-github.ps1 -Visibility private
```

`-Yes` slaat alleen de bevestigingsvraag over. Authenticatie bij GitHub blijft altijd vereist.

## Beveiliging

- Het script bewaart geen GitHub-token of wachtwoord.
- Het gebruikt de beveiligde aanmelding van GitHub CLI.
- Het gebruikt nooit `--force`.
- Als een bestaande `origin` naar een andere repository wijst, stopt het script.
- Als de GitHub-branch onbekende commits bevat, stopt het script zonder deze te overschrijven.
