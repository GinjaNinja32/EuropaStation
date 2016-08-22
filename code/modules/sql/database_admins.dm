var/list/admin_ranks = list()								//list of all ranks with associated rights

//load our rank - > rights associations
/proc/load_admin_ranks()
	admin_ranks.Cut()

	var/previous_rights = 0

	//load text from file
	var/list/Lines = file2list("config/admin_ranks.txt")

	//process each line seperately
	for(var/line in Lines)
		if(!length(line))				continue
		if(copytext(line,1,2) == "#")	continue

		var/list/List = splittext(line,"+")
		if(!List.len)					continue

		var/rank = ckeyEx(List[1])
		switch(rank)
			if(null,"")		continue
			if("Removed")	continue				//Reserved

		var/rights = 0
		for(var/i=2, i<=List.len, i++)
			switch(ckey(List[i]))
				if("@","prev")					rights |= previous_rights
				if("buildmode","build")			rights |= R_BUILDMODE
				if("admin")						rights |= R_ADMIN
				if("ban")						rights |= R_BAN
				if("fun")						rights |= R_FUN
				if("server")					rights |= R_SERVER
				if("debug")						rights |= R_DEBUG
				if("permissions","rights")		rights |= R_PERMISSIONS
				if("possess")					rights |= R_POSSESS
				if("stealth")					rights |= R_STEALTH
				if("rejuv","rejuvinate")		rights |= R_REJUVINATE
				if("varedit")					rights |= R_VAREDIT
				if("everything","host","all")	rights |= (R_HOST | R_BUILDMODE | R_ADMIN | R_BAN | R_FUN | R_SERVER | R_DEBUG | R_PERMISSIONS | R_POSSESS | R_STEALTH | R_REJUVINATE | R_VAREDIT | R_SOUNDS | R_SPAWN | R_MOD| R_MENTOR)
				if("sound","sounds")			rights |= R_SOUNDS
				if("spawn","create")			rights |= R_SPAWN
				if("mod")						rights |= R_MOD
				if("mentor")					rights |= R_MENTOR

		admin_ranks[rank] = rights
		previous_rights = rights

/hook/startup/proc/loadAdmins()
	load_admins()
	return 1

/proc/load_admins()
	//clear the datums references
	admin_datums.Cut()
	for(var/client/C in admins)
		C.remove_admin_verbs()
		C.holder = null
	admins.Cut()

	load_admin_ranks()

	if(config.sql_enabled)
		establish_database_connection()

	world.log << "Loading admins..."

	//load text from file
	var/list/Lines = file2list("config/admins.txt")

	//process each line seperately
	if(islist(Lines) && Lines.len)
		for(var/line in Lines)
			if(!length(line) || copytext(line,1,2) == "#")
				continue
			var/list/List = splittext(line, "-")
			if(List.len)
				var/ckey = ckey(List[1])
				if(ckey)
					var/rank = (List.len >= 2) ? ckeyEx(List[2]) : ""
					var/rights = admin_ranks[rank] ? admin_ranks[rank] : 0
					if(global_db)
						var/database/query/check_query = new("INSERT INTO admin VALUES ('[ckey]', '[rank]', [rights]);")
						check_query.Execute(global_db)
					else
						var/datum/admins/D = new /datum/admins(rank, rights, ckey)
						D.associate(directory[ckey])

	if(global_db)
		var/database/query/query = new("SELECT * FROM admin")
		query.Execute(global_db)
		while(query.NextRow())
			var/list/querydata = query.GetRowData()
			var/ckey = querydata["ckey"]
			var/rank = querydata["rank"]
			if(rank == "Removed") continue
			var/rights = querydata["rights"]
			if(istext(rights))
				rights = text2num(rights)
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)
			D.associate(directory[ckey])
	world.log << "Loaded."
