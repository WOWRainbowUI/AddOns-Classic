--Localization.deDE.lua
--From Elto@Kil'jaeden (OLD)
--NEW german translation by Dathwada EU-Eredar

if ( GetLocale() == "deDE" ) then
TomTomLocals = {
	["%d yards"] = "%d Meter",
	["%s (%.2f, %.2f)"] = "%s (%.2f, %.2f)",
	["%s: (map: %d, zone: %s, continent: %s, world: %s)"] = "%s: (Karte: %d, Zone: %s, Kontinent: %s, Welt: %s)",
	["%s yards away"] = "%s Meter entfernt",
	["%s%s - %s %s %s %s"] = "%s%s - %s %s %s %s",
	["%s%s - %s (map: %d)"] = "%s%s - %s (Karte: %d)",
	["%s: No coordinate information found for '%s' at this map level"] = "%s: Keine Koordinateninformationen für '%s' auf diesem Kartenlevel gefunden",
	["%sNo waypoints in this zone"] = "%sKeine Wegpunkte in dieser Zone",
	["Accept waypoints from guild and party members"] = "Erlaube Wegpunkte von Gilden- und Gruppenmitgliedern",
	["Allow closest waypoint to be outside current zone"] = "Erlaube dem nächstgelegenen Wegpunkt außerhalb der aktuellen Zone zu liegen",
	["Allow control-right clicking on map to create new waypoint"] = "Mit STRG-Rechtsklick neue Wegpunkte erstellen",
	["Allow the corpse arrow to override other waypoints"] = "Wegpunkt zur Leiche nicht überschreiben",
	["Alpha"] = "Deckkraft",
	["Announce new waypoints when they are added"] = "Neue hinzugefügte Wegpunkte ankündigen",
	["Are you sure you would like to remove ALL TomTom waypoints?"] = "Bist du dir sicher, dass du ALLE TomTom-Wegpunkte entfernen möchtest?",
	["Arrow colors"] = "Pfeilfarben",
	["Arrow display"] = "Pfeilanzeige",
	["Arrow locked"] = "Richtungspfeil fixieren",
	["Ask for confirmation on \"Remove All\""] = "Für \"Entferne alle Wegpunkte\" nachfragen",
	["Automatically set a waypoint when I die"] = "Automatisch einen Wegpunkt setzen wenn ich sterbe",
	["Automatically set to next closest waypoint"] = "Automatisch auf nächstgelegenen Wegpunkt setzen",
	["Automatically set waypoint arrow"] = "Richtungspfeil automatisch setzen",
	["Background color"] = "Hintergrundfarbe",
	["Bad color"] = "falsche Richtung",
	["Block height"] = "Höhe",
	["Block width"] = "Breite",
	["Border color"] = "Rahmenfarbe",
	["Channel to play the ping through"] = "Soundkanal",
	["Clear waypoint distance"] = "Entfernung zum löschen des Wegpunktes",
	["Clear waypoint from crazy arrow"] = "Wegpunkt für den Pfeil löschen",
	["Controls the frequency of updates for the coordinate LDB feed."] = "Kontrolliert die Häufigkeit von Aktualisierungen für die Koordinatendatenquelle.",
	["Controls the frequency of updates for the coordinate block."] = "Kontrolliert die Häufigkeit von Aktualisierungen für die Koordinatenbox.",
	["Controls the frequency of updates for the crazy arrow LDB feed."] = "Kontrolliert die Häufigkeit von Aktualisierungen für die Richtungspfeildatenquelle.",
	["Coordinate Accuracy"] = "Präzision",
	["Coordinate Block"] = "Koordinatenbox",
	["Coordinate feed accuracy"] = "Präzision",
	["Coordinate feed throttle"] = "Aktuallisierungsrate der Koordinaten",
	["Coordinates can be displayed as simple XX, YY coordinate, or as more precise XX.XX, YY.YY.  This setting allows you to control that precision"] = "Legt fest mit wie vielen Nachkommastellen die Koordinaten angezeigt werden.",
	["Coordinates can be slid from the default location, to accomodate other addons.  This setting allows you to control that offset"] = "Ermöglicht es die Koordinaten zu verschieben, um andere Addons nicht zu überlagern.",
	["Could not find any matches for zone %s."] = "Es konnten keine Treffer für die Zone %s gefunden werden.",
	["Crazy Arrow feed throttle"] = "Aktuallisierungsrate des Pfeils",
	["Create note modifier"] = "Taste für Wegpunktsetzung",
	["Cursor Coordinates"] = "Mauszeigerkoordinaten",
	["Cursor coordinate accuracy"] = "Präzision",
	["Cursor coordinate offset"] = "X-Versatz",
	["Data Feed Options"] = "Datenfeed",
	["Disable all mouse input"] = "Alle Mauseingaben deaktivieren",
	["Disables the crazy taxi arrow for mouse input, allowing all clicks to pass through"] = "Deaktiviert Mauseingaben für den Richtungspfeil und lässt dich hindurch klicken.",
	["Display Settings"] = "Anzeigeeinstellungen",
	["Display waypoints from other zones"] = "Zeige Wegpunkte aus anderen Zonen",
	["Enable automatic quest objective waypoints"] = "Aktiviere automatische Questzielwegpunkte",
	["Enable coordinate block"] = "Aktiviere die Koordinatenbox",
	["Enable floating waypoint arrow"] = "Aktiviere den beweglichen Richtungspfeil",
	["Enable minimap waypoints"] = "Aktiviere Minikarten Wegpunkte",
	["Enable mouseover tooltips"] = "Aktiviere Mausover-Tooltips",
	["Enable quest objective click integration"] = "Aktiviere Wegpunktsetzung durch Tastenkombination",
	["Enable showing cursor coordinates"] = "Aktiviere Mauszeigerkoordinaten",
	["Enable showing player coordinates"] = "Aktiviere Spielerkoordinaten",
	["Enable the right-click contextual menu"] = "Aktiviere das Kontextmenü für die rechte Maustaste",
	["Enable world map waypoints"] = "Aktiviere Weltkarten-Wegpunkte",
	["Enables a floating block that displays your current position in the current zone"] = "Aktiviert eine permanent aktualisierende Koordinatenbox, welche die aktuelle Position in der Zone anzeigt.",
	["Enables a menu when right-clicking on a waypoint allowing you to clear or remove waypoints"] = "Legt fest ob ein Kontextmenü für mehr Optionen mit der rechten Maustaste aktiviert werden soll.",
	["Enables a menu when right-clicking on the waypoint arrow allowing you to clear or remove waypoints"] = "Legt fest ob ein Kontextmenü für mehr Optionen mit der rechten Maustaste aktiviert werden soll.",
	["Enables the automatic setting of quest objective waypoints based on which objective is closest to your current location.  This setting WILL override the setting of manual waypoints."] = "Aktiviert die automatische Erstellung von Wegpunkten für Questziele basierend darauf, welches Ziel dem aktuellen Standort am nächsten liegt. \n\n|cffff0000Überschreibt die Einstellung der manuellen Wegpunkte.|r",
	["Enables the setting of waypoints when modified-clicking on quest objectives"] = "Aktiviert die Tastenkombination \"Ausgewählte Taste\" + Rechtsklick zur Wegpunktsetzung für Questziele.",
	["Exact color"] = "exakte Richtung",
	["Font size"] = "Schriftgröße",
	["Found %d possible matches for zone %s.  Please be more specific"] = "Es wurden %d mögliche Treffer für die Zone %s gefunden. Bitte sei spezifischer.",
	["Found multiple matches for zone '%s'.  Did you mean: %s"] = "Mehrere Treffer für die Zone '%s' gefunden. Meinst du: %s",
	["From: %s"] = "Von: %s",
	["General Options"] = "Allgemein",
	["Good color"] = "richtige Richtung",
	["Hide the crazy arrow display during pet battles"] = "Verstecke den Pfeil während Haustierkämpfen",
	["Icon Control"] = "Symboleinstellung",
	["If you have changed the waypoint display settings (minimap, world), this will re-set all waypoints to the current options."] = "Wenn die Einstellungen für die Wegpunktanzeige (Minikarte, Welt) geändert wurden, werden hiermit alle Wegpunkte auf die aktuellen Optionen gesetzt.",
	["If your arrow is covered up by something else, try this to bump it up a layer."] = "Wenn der Pfeil von etwas anderem verdeckt wird, versuche dies um den Pfeil wieder in den Vordergrund zu bringen.",
	["Lock coordinate block"] = "Koordinatenbox fixieren",
	["Lock waypoint arrow"] = "Richtungspfeil fixieren",
	["Locks the coordinate block so it can't be accidentally dragged to another location"] = "Fixiert die Koordinatenbox, sodass sie nicht mehr verschoben werden kann.",
	["Locks the waypoint arrow, so it can't be moved accidentally"] = "Fixiert den Richtungspfeil, sodass er nicht mehr verschoben werden kann.",
	["Middle color"] = "\"beinahe\" Richtung",
	["Minimap"] = "Minikarte",
	["Minimap Icon"] = "Minikartensymbol",
	["Minimap Icon Size"] = "Minikartensymbolgröße",
	["My Corpse"] = "Meine Leiche",
	["No"] = "Nein",
	["Normally when TomTom sets the closest waypoint it chooses the waypoint in your current zone. This option will cause TomTom to search for any waypoints on your current continent. This may lead you outside your current zone, so it is disabled by default."] = "Wenn TomTom den nächstgelegenen Wegpunkt festlegt, wählt es normalerweise den Wegpunkt in der aktuellen Zone aus. Diese Option veranlasst TomTom dazu nach Wegpunkten auf dem aktuellen Kontinent zu suchen. Dies kann dazu führen, dass du außerhalb deiner aktuellen Zone geführt wirst, daher ist dies standardmäßig deaktiviert.",
	["Options profile"] = "Einstellungsprofil",
	["Options that alter quest objective integration"] = "",
	["Options that alter the coordinate block"] = "Einstellungen der Koordinatenbox",
	["Place the arrow in the HIGH strata"] = "Platziere den Pfeil im Vordergrund",
	["Play a sound when arriving at a waypoint"] = "Spiele einen Ton ab wenn der Wegpunkt erreicht wurde",
	["Player Coordinates"] = "Spielerkoordinaten",
	["Player coordinate accuracy"] = "Präzision",
	["Player coordinate offset"] = "X-Versatz",
	["Profile Options"] = "Profileinstellungen",
	["Prompt before accepting sent waypoints"] = "Nachfragen bevor Wegpunkte gesendet werden",
	["Provide a LDB data source for coordinates"] = "Koordinaten LDB Datenquelle zur Verfügung stellen",
	["Provide a LDB data source for the crazy-arrow"] = "Richtungspfeil LDB Datenquelle zur Verfügung stellen",
	["Quest Objectives"] = "Questziele",
	["Remove all waypoints"] = "Alle Wegpunkte entfernen",
	["Remove all waypoints from this zone"] = "Alle Wegpunkte aus dieser Zone entfernen",
	["Remove waypoint"] = "Wegpunkt entfernen",
	["Removed %d waypoints from %s"] = "%d Wegpunkte entfernt von %s",
	["Reset Position"] = "Position zurücksetzen",
	["Reset waypoint display options to current"] = "Wegpunktanzeige auf aktuell setzen",
	["Resets the position of the waypoint arrow if its been dragged off screen"] = "Setzt die Position zurück.", -- for Waypoint arrow and coordblock used.
	["Save new waypoints until I remove them"] = "Neue Wegpunkte speichern, bis sie explizit gelöscht werden",
	["Save profile for TomTom waypoints"] = "Speicherprofil für TomTom Wegpunkte",
	["Save this waypoint between sessions"] = "Speichere diesen Wegpunkt zwischen Sitzungen",
	["Saved profile for TomTom options"] = "Gespeicherte Profile für TomTom Einstellungen",
	["Scale"] = "Pfeilskalierung",
	["Send to battleground"] = "an Schlachtfeld",
	["Send to guild"] = "an Gilde",
	["Send to party"] = "an Gruppe",
	["Send to raid"] = "an Schlachtzug",
	["Send waypoint to"] = "Sende Wegpunkt",
	["Set as waypoint arrow"] = "als Richtungspfeil setzen",
	["Show estimated time to arrival"] = "Zeige geschätze Ankunftszeit",
	["Show the distance to the waypoint"] = "Zeige die Entfernung zum Wegpunkt",
	["Shows an estimate of how long it will take you to reach the waypoint at your current speed"] = "Geschätze Zeit, wie lange es dauert, bis der Wegpunkt mit der aktuellen Geschwindigkeit erreicht wird.",
	["Shows the distance (in yards) to the waypoint"] = "Zeigt die Entfernung (in Metern) zum Wegpunkt an.",
	["The color to be displayed when you are halfway between the direction of the active waypoint and the completely wrong direction"] = "Legt die Farbe des Pfeils fest, wenn die Blickrichtung sich nicht in Richtung des Wegpunktes aber auch nicht in dessen entgegengesetzter Richtung befindet.",
	["The color to be displayed when you are moving in the direction of the active waypoint"] = "Legt die Farbe des Pfeils fest, wenn die Blickrichtung sich in Richtung zum Wegpunkt befindet.",
	["The color to be displayed when you are moving in the exact direction of the active waypoint"] = "Legt die Farbe des Pfeils fest, wenn die Blickrichtung sich in exakter Richtung zum Wegpunkt befindet.",
	["The color to be displayed when you are moving in the opposite direction of the active waypoint"] = "Legt die Farbe des Pfeils fest, wenn die Blickrichtung sich in entgegengesetzter Richtung zum Wegpunkt befindet.",
	["The display of the coordinate block can be customized by changing the options below."] = "Die Anzeige der Koordinatenbox kann mit den unten stehenden Einstellungen geändert werden.",
	["The floating waypoint arrow can change color depending on whether or nor you are facing your destination.  By default it will display green when you are facing it directly, and red when you are facing away from it.  These colors can be changed in this section.  Setting these options to the same color will cause the arrow to not change color at all"] = "Der bewegliche Richtungspfeil ändert seine Farbe in Abhängikeit der Blickrichtung zum Wegpunkt. In Blickrichtung des Wegpunktes ist der Pfeil standardmäßig grün und  in entgegengesetzter Richtung rot. Diese Farben können hier eingestellt werden. Werden alle Farben auf den gleichen Wert gesetzt, ändert der Pfeil seine Farbe nicht.",
	["There were no waypoints to remove in %s"] = "Es gab keine Wegpunkte zum Entfernen in %s.",
	["These options let you customize the size and opacity of the waypoint arrow, making it larger or partially transparent, as well as limiting the size of the title display."] = "Mit diesen Optionen kann die Skalierung und Deckkraft des Richtungspfeils angepasst werden.",
	["This option will not remove any waypoints that are currently set to persist, but only effects new waypoints that get set"] = "Legt fest ob neu gesetzte Wegpunkte bis zu ihrer Löschung bestehen bleiben sollen. Betrifft nur Wegpunkte die nach dem aktivieren dieser Option erstellt werden. \n|cffff0000Wegpunkte werden beim erreichen ihres Zieles gelöscht wenn die Option \"Entfernung zum löschen des Wegpunktes\" gestezt ist.|r",
	["This option will toggle whether or not you are asked to confirm removing all waypoints.  If enabled, a dialog box will appear, requiring you to confirm removing the waypoints"] = "Wenn aktiviert, wird ein Dialogfeld angezeigt, in dem das Entfernen aller Wegpunkte bestätigt werden muss.",
	["This setting allows you to change the opacity of the title text, making it transparent or opaque"] = "Legt die Deckkraft des Titeltextes fest um sie transparent oder undurchsichtig zu machen.",
	["This setting allows you to change the opacity of the waypoint arrow, making it transparent or opaque"] = "Legt die Deckkraft des Wegpunktpfeiles fest um ihn transparent oder undurchsichtig zu machen.",
	["This setting allows you to change the scale of the waypoint arrow, making it larger or smaller"] = "Legt die Skalierung des Wegpunktpfeils fest um ihn größer oder kleiner zu machen.",
	["This setting allows you to control the default size of the minimap icon. "] = "Legt die Standardgröße der Minikartensymbole fest.",
	["This setting allows you to control the default size of the world map icon"] = "Legt die Standardgröße der Weltkartensymbole fest.",
	["This setting allows you to select the default icon for the minimap"] = "Legt das Standardsymbol für die Minikarte fest.",
	["This setting allows you to select the default icon for the world map"] = "Legt das Standardsymbol für die Weltkarte fest.",
	["This setting allows you to specify the maximum height of the title text.  Any titles that are longer than this height (in game pixels) will be truncated."] = "Legt die maximale höhe des Titeltextes fest. Alle Titel die länger als diese Höhe sind (in pixeln) werden abgeschnitten.",
	["This setting allows you to specify the maximum width of the title text.  Any titles that are longer than this width (in game pixels) will be wrapped to the next line."] = "Legt die maximale Breite des Titeltextes fest. Alle Titel die länger als diese Breite sind (in pixeln) werden in die nächste Zeile verschoben.",
	["This setting allows you to specify the scale of the title text."] = "Legt die Skalierung des Titeltextes fest.",
	["This setting changes the modifier used by TomTom when right-clicking on a quest objective POI to create a waypoint"] = "Ändert die von TomTom verwendete Taste mit der per rechter Maustaste für das Questziel ein Wegpunkt erstellt werden soll.",
	["This setting changes the modifier used by TomTom when right-clicking on the world map to create a waypoint"] = "Ändert die von TomTom verwendete Taste mit der per rechter Maustaste auf der Weltkarte ein Wegpunkt erstellt werden soll.",
	["This setting will control the distance at which the waypoint arrow switches to a downwards arrow, indicating you have arrived at your destination"] = "Diese Einstellung legt die Entfernung fest, bei der der Richtungspfeil sich zu einem Abwärtspfeil wandelt, zur Anzeig, dass das Ziel erreicht wurde.",
	["Title Alpha"] = "Titeldeckkraft",
	["Title Height"] = "Titelhöhe",
	["Title Scale"] = "Titelskalierung",
	["Title Width"] = "Titelbreite",
	["TomTom Waypoint Arrow"] = "TomTom Richtungspfeil",
	["TomTom can announce new waypoints to the default chat frame when they are added"] = "Legt fest ob neu hinzugefügte Wegpunkte im Standard-Chat-Frame angekündigt werden sollen.",
	["TomTom can automatically set a waypoint when you die, guiding you back to your corpse"] = "Legt fest ob ein Wegpunkt gesetzt werden soll wenn du stirbst, der dich zu deiner Leiche zurückführt.",
	["TomTom can be configured to set waypoints for the quest objectives that are shown in the watch frame and on the world map.  These options can be used to configure these options."] = "TomTom kann so eingestellt werden, dass Wegpunkte für die Questziele festgelegt werden, die im Questfenster und auf der Weltkarte angezeigt werden.",
	["TomTom can display a tooltip containing information abouto waypoints, when they are moused over.  This setting toggles that functionality"] = "Zeige Tooltips zu den Wegpunkten wenn die Maus sich darüber befindet.",
	["TomTom can display multiple waypoint arrows on the minimap.  These options control the display of these waypoints"] = "Beeinflusst die Darstellung wie Wegpunkte in der Minikarte angezeigt werden sollen.",
	["TomTom can display multiple waypoints on the world map.  These options control the display of these waypoints"] = "Beeinflusst die Darstellung wie Wegpunkte auf der Weltkarte angezeigt werden sollen.",
	["TomTom can hide waypoints in other zones, this setting toggles that functionality"] = "Legt fest ob Wegpunkte in anderen Zonen angezeigt oder versteckt werden sollen.",
	["TomTom is capable of providing data sources via LibDataBroker, which allows them to be displayed in any LDB compatible display.  These options enable or disable the individual feeds, but will only take effect after a reboot."] = "TomTom kann Datenquellen über LibDataBroker für andere Addons bereitstellen, sodass sie in LDB-kompatiblen Anzeigen genutzt werden können. Diese Optionen aktivieren oder deaktivieren die einzelnen Datenquellen. \n|cffff0000Änderungen werden erst nach einem Neuladen des UI wirksam.|r",
	["TomTom provides an arrow that can be placed anywhere on the screen.  Similar to the arrow in \"Crazy Taxi\" it will point you towards your next waypoint"] = "TomTom unterstützt einen Richtungspfeil, der überall auf dem Bildschirm positioniert werden kann.",
	["TomTom provides you with a floating coordinate display that can be used to determine your current position.  These options can be used to enable or disable this display, or customize the block's display."] = "TomTom unterstützt eine Koordinatenbox, welche die aktuelle Position anzeigt. \nIn diesen Einstellungen kann die Funktion ein-, ausgeschaltet und die Darstellung geändert werden.",
	["TomTom waypoint"] = "TomTom Wegpunkt",
	["TomTom's saved variables are organized so you can have shared options across all your characters, while having different sets of waypoints for each.  These options sections allow you to change the saved variable configurations so you can set up per-character options, or even share waypoints between characters"] = "TomToms gespeicherte Einstellungen sind so organisiert, dass sie gemeinsame Optionen für all ihre Charakter haben, aber unterschiedliche Wegpunkte für jeden. Dieser Einstellungsabschnitt erlaubt es ihnen, die gespeicherten Konfigurationen pro Charakter fest zu legen, oder Wegpunkte zu teilen.",
	["Unknown distance"] = "Unbekannte Distanz",
	["Unknown waypoint"] = "Unbekannter Wegpunkt",
	["Update throttle"] = "Aktuallisierungsrate",
	["Wayback"] = "Rückweg",
	["Waypoint Arrow"] = "Richtungspfeil",
	["Waypoint Options"] = "Wegpunktoptionen",
	["Waypoint communication"] = "Wegpunktkommunikation",
	["Waypoint from %s"] = "Wegpunkt von %s.",
	["Waypoints can be automatically cleared when you reach them.  This slider allows you to customize the distance in yards that signals your \"arrival\" at the waypoint.  A setting of 0 turns off the auto-clearing feature\n\nChanging this setting only takes effect after reloading your interface."] = "Legt fest ob Wegpunkte automatisch gelöscht werden, wenn sie erreicht wurden. Dieser Schieberegler stellt die Entfernung in Meter zum Ziel ein, in der der Wegpunkt als \"erreicht\" gilt. Eine 0 als Einstellung schaltet die automatische Wegpunktlöschung aus. \n\n|cffff0000Änderungen werden erst nach einem Neuladen des UI wirksam.|r",
	["Waypoints profile"] = "Wegpunktprofile",
	["When a 'ping' is played, use the indicated sound channel so the volume can be controlled."] = "Verwendet den angegebenen Soundkanal um Töne abzuspielen um damit die Lautstärke zu steuern.",
	["When a new waypoint is added, TomTom can automatically set the new waypoint as the \"Crazy Arrow\" waypoint."] = "Wurde ein neuer Wegpunkt hinzugefügt, kann TomTom diesen Punkt automatisch als neuen Richtungspfeil setzen.",
	["When a pet battle begins, the crazy arrow will be hidden from view. When you exit the pet battle, it will be re-shown."] = "Wenn eine Haustierkampf beginnt, wird der Richtungspfeil für dessen Dauer versteckt.",
	["When the current waypoint is cleared (either by the user or automatically) and this option is set, TomTom will automatically set the closest waypoint in the current zone as active waypoint."] = "Wenn der aktuelle Wegpunkt gelöscht wird (entweder vom Benutzer oder automatisch) und diese Option aktiviert ist, legt TomTom automatisch den nächstgelegenen Wegpunkt in der aktuellen Zone als aktiven Wegpunkt fest.",
	["When the player is dead and has a waypoint towards their corpse, it will prevent other waypoints from changing the crazy arrow"] = "Legt fest ob der Richtungspfeil zur Spielerleiche beibehalten werden soll oder von anderen Wegpunkten geändert werden darf.",
	["When you 'arrive' at a waypoint (this distance is controlled by the 'Arrival Distance' setting in this group) a sound can be played to indicate this.  You can enable or disable this sound using this setting."] = "Wenn ein Wegpunkt erreicht wird (diese Entfernung wird durch die Einstellung \"Entfernung zum Ziel\" in dieser Gruppe gesteuert), kann ein Ton abgespielt werden, um dies zu signalisieren.",
	["World Map"] = "Weltkarte",
	["World Map Icon"] = "Weltkartensymbol",
	["World Map Icon Size"] = "Weltkartensymbolgröße",
	["Yes"] = "Ja",
	["You are at (%s) in '%s' (map: %s)"] = "Du bist bei (%s) in '%s' (Karte: %s).",
	["\"Arrival Distance\""] = "\"Entfernung zum Ziel\"",
	["is"] = "ist",
	["not"] = "nicht",
	["set waypoint modifier"] = "Taste für Wegpunktsetzung",
	["|cffffff78/cway |r - Activate the closest waypoint"] = "|cffffff78/cway |r - Aktiviert den nächstgelegenen Wegpunkt.",
	["|cffffff78/tomtom |r - Open the TomTom options panel"] = "|cffffff78/tomtom |r - Öffnet das TomTom Optionsmenü.",
	["|cffffff78/way /tway /tomtomway |r - Commands to set a waypoint: one should work."] = "|cffffff78/way /tway /tomtomway |r - Befehle um einen Wegpunkt zu setzen: einer sollte reichen.",
	["|cffffff78/way <x> <y> [desc]|r - Adds a waypoint at x,y with descrtiption desc"] = "|cffffff78/way <x> <y> [desc]|r - Fügt einen Wegpunkt bei x,y mit einer Beschreibung hinzu.",
	["|cffffff78/way <zone> <x> <y> [desc]|r - Adds a waypoint at x,y in zone with description desc"] = "|cffffff78/way <zone> <x> <y> [desc]|r - Fügt einen Wegpunkt bei x,y in der Zone mit einer Beschreibung hinzu.",
	["|cffffff78/way arrow|r - Prints status of the Crazy Arrow"] = "|cffffff78/way arrow|r - Gibt einen Status des Pfeils aus.",
	["|cffffff78/way block|r - Prints status of the Coordinate Block"] = "|cffffff78/way block|r - Gibt einen Status der Koordinatenbox aus.",
	["|cffffff78/way list|r - Lists all active waypoints"] = "|cffffff78/way list|r - Listet alle aktive Wegpunkte auf.",
	["|cffffff78/way local|r - Lists active waypoints in current zone"] = "|cffffff78/way local|r - Listet aktive Wegpunkte in der aktuellen Zone auf.",
	["|cffffff78/way reset <zone>|r - Resets all waypoints in zone"] = "|cffffff78/way reset <zone>|r - Setzt alle Wegpunkt in dieser Zone zurück.",
	["|cffffff78/way reset all|r - Resets all waypoints"] = "|cffffff78/way reset all|r - Setzt alle Wegpunkt zurück.",
	["|cffffff78/way reset away|r - Resets all waypoints not in current zone"] = "|cffffff78/way reset away|r - Setzt alle Wegpunkt außerhalb der aktuellen Zone zurück.",
	["|cffffff78/way reset not <zone>|r - Resets all waypoints not in zone"] = "|cffffff78/way reset not <zone>|r - Setzt alle Wegpunkt außerhalb dieser Zone zurück.",
	["|cffffff78TomTom |r/way /tway /tomtomway /cway /tomtom |cffffff78Usage:|r"] = "|cffffff78TomTom |r/way /tway /tomtomway /cway /tomtom |cffffff78Verwendung:|r",
	["|cffffff78TomTom:|r Added a waypoint (%s%s%s) in %s"] = "|cffffff78TomTom:|r Wegpunkt (%s%s%s) in %s hinzugefügt.",
	["|cffffff78TomTom:|r CoordBlock %s visible"] = "|cffffff78TomTom:|r Koordinatenbox %s sichtbar.",
	["|cffffff78TomTom:|r Could not find a closest waypoint in this continent."] = "|cffffff78TomTom:|r Auf diesem Kontinent konnte kein nächstgelegenen Wegpunkt gefunden werden.",
	["|cffffff78TomTom:|r Could not find a closest waypoint in this zone."] = "|cffffff78TomTom:|r In dieser Zone konnte kein nächstgelegenen Wegpunkt gefunden werden.",
	["|cffffff78TomTom:|r CrazyArrow %s hijacked"] = "|cffffff78TomTom:|r CrazyArrow %s entführt.",
	["|cffffff78TomTom:|r CrazyArrow %s visible"] = "|cffffff78TomTom:|r CrazyArrow %s sichtbar.",
	["|cffffff78TomTom:|r Selected waypoint (%s%s%s) in %s"] = "|cffffff78TomTom:|r Wegpunkt (%s%s%s) in %s ausgewählt.",
	["|cffffff78TomTom:|r Waypoint %s valid"] = "|cffffff78TomTom:|r Waypoint %s gültig.",
	["|cffffff78TomTom|r: Added '%s' (sent from %s) to zone %s"] = "|cffffff78TomTom|r: Hinzugefügt '%s' (gesendet von %s) zu Zone %s.",
	["Old Gold Green Dot"] = "Alter goldgrüner Punkt",
	["New Gold Blue Dot"] = "Neuer goldblauer Punkt",
	["New Gold Green Dot"] = "Neuer goldgrüner Punkt",
	["New Gold Purple Dot"] = "Neuer goldvioletter Punkt",
	["New Gold Red Dot"] = "Neuer goldroter Punkt",
	["New Purple Ring"] = "Neuer violetter Kreis",
	["Player: ---"] = "Spieler: ---",
	["Player: %s"] = "Spieler: %s",
	["Cursor: ---"] = "Maus: ---",
	["Cursor: %s"] = "Maus: %s",
}

setmetatable(TomTomLocals, {__index=function(t,k) rawset(t, k, k); return k; end})

end