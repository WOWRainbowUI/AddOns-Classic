# Changelog old versions

## v2.56
* live release for cata 4.4.1
* bug fix for aura detection (fixes ignite holder)

## v2.55
* update for classic 1.15.4 and cata 4.4.1
* replaced EasyMenu with new Blizzard Menu API
* This is breaking old TBC and WOTLK Interface compatibility!

## v2.54
* update for classic 1.15.3

## v2.53
* fix wotlk warning in curseforge updater

## v2.52

* Updated TOC for Cataclysm 40400
* Updated TOC for Classic Era 11502
* Updated Ace libs

## v2.51

Updated TOC for Classic Era 11501

## v2.50

Updated TOC for Classic Era 11500

## v2.49

Updated TOC for WotLK 30403 and Classic Era 11404

## v2.48

Updated TOC for WotLK 30402

## v2.47

Updated for WotLK 30401
* fixed SetMinResize / SetMaxResize renamed to SetResizeBounds
* fixed invalid values provided to SetAlpha during screenflash
* rate limit frame resize call to prevent lag
* updated libs

## v2.46
* fixed a bug that made the bar background incorrectly configurable. the backdrop texture can now be correctly configured. Changed the config settings, so you might have to reconfigure color and texture of your backdrop. Your old settings are still available as backdrop.bgTexture and backdrop.bgColor in your config file in the WTF folder.
* added yogg laughing as an aggro warning sound

## v2.45
* works in wotlk beta
* update libaries
* added media for my favorite bar style Minimalist

## v2.44
* adjust toc for AQ40 Season of Mastery

## v2.43
* adjust toc for Zul'Aman BCC

## v2.42
* adjust toc for Hyjal/BT BCC

## v2.41
* adjust toc for Season of Mastery

## v2.40
* Added new option to grow bars bottom up

## v2.39
* Updated translations and bump interface version

## v2.38

* Fixed a bug that made it impossible to change the backdrop texture
* Fixed a lua error that could occur when filtering range players
* Fixed backdrop being incorrectly drawn above bars. Backdrop now draws behind bars, while the edge still draws above. This removes the faint white taint on your bars with the default settings.

## v2.37

* Release chinese localization

## v2.36

Major update!

* Added out of melee range filter. This hides players that are not in melee range. This can be enabled for only configured targets or all targets.
* Added option to disable warnings while tanking (you are considered tanking in def stance, bear form or with righteous fury active)
* Bar backdrop and edge are now configurable
* Update shared media widget

## v2.35
* Update embedded Ace libs

## v2.34
* rerelease with updated packager (BCC compatible classic release in v2.33 got broken by packager)

## v2.33
* add BCC.toc to classic package, so any package works on both clients

## v2.32
* official TBC release


## v2.31
* bump interface version to 11307

## v2.30
* add backdrop mixin for TBC client

## v2.29
* Fixed unnecessary threat warnings when the Blizzard API  incorrectly returns 250% threat percentage (e.g. on threat wipe abilities)

## v2.28
* Switch to GitHub actions packager workflow

## v2.27
* Fix a small mistake in fr translation that caused lua errors

## v2.26
* Update various translations
* Update WoW Interface Version to 1.13.6

## v2.25
* Added two ignite tracking options (bar color and icon)
* Threat value and percentage can no be toggled on and off
* fixed a lua error when the window height was set too high
* fixed a rare lua error when the player ran out of draw distance

## v2.24
* Fixed Not in guild error upon login
* update CN translation
* update RU translation
* some code cleanup

## v2.23
* Added a fix for wrong raw threat percentages returned by Blizzard API.

## v2.22
* Small bug fix for the /tc2 version command
* Update Chinese translations

## v2.21
* LibThreatClassic2 was completely removed from the addon.
* Added two new warning sounds
* Added an outdated version announcement for TC2.

## v2.20

* Prepared the addon to use the threat api when available (from patch 1.13.5)
* Added an option to downscale threat to the current numbers (i.e. 1 damage = 1 threat. threat api uses 1 damage = 100 threat). Hidden until api is available.
* Removed the nameplate feature. It wasn't working correctly. Please install a dedicated nameplate addon, if you need threat colored nameplates.
* added korean and updated chinese translations


## v2.19

* fix threat warnings not working in raids
* fix background texture not loading properly
* add min threat amount to show warnings
* add smaller positioning options for frame positon (up to 0.01)
* update chinese translations

## v2.18

* fixed a small bug that caused toggled settings not to be copied to the new profiles

## v2.17

* Bump LibThreatClassic2 to revision 12
    * improve buff handling (fixes tranquil totem and blessing of salvation issues)
    * improve paladin blessing threat tracking (still not perfect)
    * add french translation for Nefarian classcall
    * add UnitThreatPercentageOfLoad to public interface
    * always return boolean for isTanking from UnitDetailedThreatSituation
* added support for profiles (imports your current settings to a new character profile **once**)
* added custom color options for current tank and for other units
* added bar texture selection to options
* always display the player if he has threat (when sized to 1 bar, this only displays the player)
* made table update frequency configurable (does not influence incoming rate of other players threat)
* fix odd resizing beheavior and added positioning to config
* does no longer display a warning, when losing aggro as a tank
* added option to display raw threat percentage (pull at 110% or 130% depending on range)

## v2.16

*  Bump LibThreatClassic2 to revision 11
    - improved thunderfury handling

## v2.15

* rename screen flashing parameter so it's correctly disabled by default
* correctly consider flash setting

## v2.14

* remove percentage overwrite for max threat target and rely on LTC2 output
* use Blizzard default font for china/korea/taiwan

## v2.13

* Bump LibThreatClassic2 to revision 10
    - fix bonus threat on missed casts
    - use taunt debuff instead of cast for taunt tracking
    - fix hunter feign death resist handling
    - add thunderfury proc bonus threat
    - fix silent resolve for shadow spells
    - add Hakkar Aspect of Arlokk handling
* add visual and sound warning on certain thresholds while not tanking
* fix dragging error when locked
* enable threat updates when out of combat
* improve player target tracking
* fix table not showing on battle start, when hide ooc is enabled
* add font selector in appearance settings

## v2.12

* Delay updates up to 0.2 seconds to address performance issues
* Only update frame on changes for current target
* Bump LibThreatClassic2 to revision 9
    - Add cleave threat modifier
    - Fix Paladin Greater Blessing bug on pets
    - Blacklist various enemies in BWL
* Update player target, if target target changes
* Added option to hide when not in an instance (also hides world bosses!)
* Improved Version checks
* Added zhTW translations

## v2.11

* Update LibThreatClassic to revision 8. Brings better threat sync interval and blacklist Lashlayer trash whelps.
* Fix some lib loading issues.
* added a /tc2 debug command to toggle LibThreatClassic2 debug output
* added a /tc2 runSolo command to toggle LibThreatClassic2 runSolo option
* added a /tc2 logThreat command to toggle LibThreatClassic2 logThreat option

## v2.10

* Use "target" as a fallback for player target, if other options make no sense (e.g. at vael)

## v2.09

* Update LibThreatClassic2 to revision 7
* Added option to change color of the player bar
* enable support for custom class colors addon
* save variables per character
* fix friendly units turning hostile

## v2.08-alpha1

Removed LibThreatClassic2 from files
added pkgmeta
embed LibThreatClassic2-r6-alpha1

## v2.07

First relase as ThreatClassic2 with LibThreatClassic2-r5