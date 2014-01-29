# To add a new language:
# pybabel init -i messages.pot -d translations -l de

extract:
	pybabel extract -o messages.pot .

compile:
	pybabel compile -f -d translations

update:
	pybabel update -i messages.pot -d translations
