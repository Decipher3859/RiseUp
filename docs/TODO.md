# TODO

## todo

- [ ] Habit Overview
    - [ ] MonatsKalender zur Übersicht
        - [ ] Ab StartDate
        - [ ] Geplante Tage einfärben
        - [ ] Abgehakte Tage einfärben
        - [ ] onTap nachträglich abhaken können
- [ ] Benachrichtigungen einrichten
    - [ ] Scheduled Notifications werden zwar in Android gespeichert, sie werden aber nie ausgelöst.


## doing



## done
- [x] Wochentagsleiste Logik auf neues Design anpassen
    - [x] Tag und Datum ändern sich nicht nachvollziehbar. Problem herausfinden.
- [x] HabitCheckButton erstellen: bei onTap inkrement Image => Pflanze wächst
- [x] ProgressCircle in HabitsPage mit Datenbank verdrahten
- [x] CheckHabitButton State auch nach Reboot korrekt anzeigen
    - [x] isDone
    - [x] progressIndex
    - [x] refresh der HabitsRows sieht technisch schlecht umgesetzt aus
        - Für einen kurzen Moment sieht man den Rebuild, obwohl sich der inhalt nicht ändert.
- [x] BUG: Manchmal wird der ProgressIndex nicht richtig angezeigt
    - Er steht auf eins, obwohl kein TagAusgewählt wurde
    - Ich vermute, das hat was mit dem Zeitpunkt des Rebuilds zu tun, denn wenn ich die Zeite komplett wechsle, ist alle wieder in Ordnung
- [x] Delete Habit Button
- [x] isActive Toggle
