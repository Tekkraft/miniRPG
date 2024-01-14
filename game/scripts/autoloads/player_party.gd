extends Node

const party_limit = 3

var party_units = []
var reserve_units = []

func new_unit(unit : Unit, main_party : bool):
	if main_party:
		if len(party_units) >= party_limit:
			return false
		
		party_units.append(unit)
	else:
		reserve_units.append(unit)
	
	return true

func add_party(unit : Unit):
	if len(party_units) >= party_limit:
		return false
	if party_units.has(unit):
		return false
	if not reserve_units.has(unit):
		return false
	
	party_units.append(unit)
	reserve_units.erase(unit)
	return true

func remove_party(unit : Unit):
	if not party_units.has(unit):
		return false
	if reserve_units.has(unit):
		return false
	
	reserve_units.append(unit)
	party_units.erase(unit)
	return true

func swap_party(add_unit : Unit, remove_unit : Unit):
	if not party_units.has(remove_unit):
		return false
	if reserve_units.has(remove_unit):
		return false
	if party_units.has(add_unit):
		return false
	if not reserve_units.has(add_unit):
		return false
	
	reserve_units.append(remove_unit)
	party_units.erase(add_unit)
	reserve_units.append(add_unit)
	party_units.erase(remove_unit)
	return true
