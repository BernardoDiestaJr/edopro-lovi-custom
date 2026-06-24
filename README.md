# EDOPro Custom Cards by Lovinauld

A repository of custom Yugioh cards scripted by Lovinauld, from Touhou to custom archetypes for the EDOPro Simulator.

# Custom Archetypes (Located at /cards-lovi.cdb)
A variety of custom archetypes I have designed and scripted.
- *"Fantasia"* - Is an archetype of cards based on the Touhou Project series, consisting of the following sub-archetypes:
  - *"Reimu the Eternal Shrine Maiden"* - This archetype includes "Reimu the Eternal Shrine Maiden," the main protagonist of the Touhou Project series, and her variants.
  - *"Divine Implement"* - Mainly consisting of spells, traps, and non-Illusion monsters, this archetype supports "Reimu the Eternal Shrine Maiden," "Onmyō," and "Fantasia" archetypes.
  - *"Onmyō"* - Another supporting archetype for "Reimu the Eternal Shrine Maiden" and "Fantasia" archetypes.
  - *"Aunn"* - Another supporting archetype mainly for the "Reimu the Eternal Shrine Maiden" archetype.
- *"Mystikrios"* - Is an archetype of cards that revolve around the Mystical Sheep #2.
- *"Kyrio"* - Is an archetype of mostly level 12 Sea-Serpents.
- *"Piscera"* - Is an archetype of mostly Flip Fish monsters based on the Early to Late Devonian Period, also known as the "Age of Fishes".
- *"Umbriazic"* - Is an archetype of EARTH and DARK Dinosaur monsters.

# Unofficial Fanmade Archetype Support Cards (Located at /cards-unofficial-support.cdb)
A collection of cards that directly or indirectly supports old or unplayable archetypes.
- *"Gusto"*
- *"Doll Monster"*
- *"Worm"*
- *"TBA"*

# How to Install the repository
To begin installing this repository, edit the **config.json** file, which is typically located in the ***ProjectIgnis/configs*** folder.
It is recommended to use **Notepad ++** or any software that can easily edit a .json file. Next, below the "repos" section of the file, create a new line and enter the following code:

```json
		{
			"url": "https://github.com/BernardoDiestaJr/edopro-lovi-custom",
			"repo_name": "Lovinauld Custom Cards",
			"repo_path": "./repositories/lovi-custom",
			"lflist_path": ".",
			"should_update": true,
			"should_read": true
		},
```
Finally, open or restart EDOPro, wait for the files to download, and you should be able to start playing with the custom cards!

**DON'T FORGET** to see the custom cards in the card catalogue, you must navigate to the Decks section and, in Deck editing, enable the **Alternate Formats** option.
