(*
Veritrope.com
Export Evernote Items to DayOne
Version 0.98 (Beta 2)
September 5, 2012

// TERMS OF USE:
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

// LIKE THIS SCRIPT?
If this AppleScript is helpful to you, please show your support here: 
http://veritrope.com/support

// SCRIPT INFORMATION AND UPDATE PAGE
http://veritrope.com/code/export-evernote-items-to-day-one

// REQUIREMENTS
** THIS SCRIPT REQUIRES YOU TO DOWNLOAD THE DAYONE COMMAND LINE APP:
http://dayoneapp.com/downloads/dayone-cli.pkg

// CHANGELOG
Version 0.98			- UPDATED TO USE NEW CLI APP
		0.91 			- Added Optional Header
            0.90 (Beta 1) 	- Initial Release

*)

(* 
======================================
// USER SWITCHES (YOU CAN CHANGE THESE!)
======================================
*)

-- IF YOU'D LIKE THE SCRIPT TO CREATE A 
-- "HEADER LINE" FOR THE DAY ONE ENTRY USING
-- THE TITLE OF THE EVERNOTE ITEM, THEN
-- CHANGE THIS VALUE TO "ON"…
property dayHeader : "OFF"

-- IF THIS PROPERTY IS SET TO "ON",
-- THEN IT WILL EXPECT THE TITLES
-- TO BE IN THE FORMAT "20130718-notes"
-- THE DATE OF THE JOURNAL ENTRY WILL BE
-- PARSED FROM THIS TITLE
property extractDateFromTitle : "OFF"

(* 
======================================
// PROPERTIES (USE CAUTION WHEN CHANGING)
======================================
*)
property noteName : ""
property noteCreated : ""
property noteHTML : ""
property noteLink : ""
property note_Date : ""

(* 
======================================
// MAIN PROGRAM 
======================================
*)
tell application "Evernote"
	set selected_Items to selection
	repeat with selected_Item in selected_Items
		--GET THE EVERNOTE DATA
		my getEvernote_Info(selected_Item)
		
		--CONVERT HTML TO PLAIN TEXT
		set note_Text to my convert_Plaintext(noteHTML)
		
		--CONVERT DATE TO PLAIN TEXT STRING		
		if extractDateFromTitle is "ON" then
			set note_Date to my convert_title_to_date(noteName)
		else
			set note_Date to my convert_Date(noteCreated)
		end if
		
		
		--MAKE THE NEW ITEM IN DAY ONE
		my make_DayOne(noteName, note_Date2, note_Text, noteLink)
		
	end repeat
end tell

(* 
======================================
// PREPARATORY SUBROUTINES 
======================================
*)

--GET THE EVERNOTE DATA
on getEvernote_Info(theNotes)
	tell application "Evernote"
		try
			set noteID to (local id of item 1 of theNotes)
			set noteName to (title of item 1 of theNotes)
			set noteSource to (source URL of item 1 of theNotes)
			set noteCreated to (creation date of item 1 of theNotes)
			set noteModified to (modification date of item 1 of theNotes)
			set noteTags to (tags of item 1 of theNotes)
			set noteAttachments to {attachments of item 1 of theNotes}
			set noteAltitude to (altitude of item 1 of theNotes)
			set noteENML to (ENML content of item 1 of theNotes)
			set noteHTML to (HTML content of item 1 of theNotes)
			set noteLat to (latitude of item 1 of theNotes)
			set noteLong to (longitude of item 1 of theNotes)
			set noteNotebook to (name of notebook of item 1 of theNotes)
			set noteLink to (note link of item 1 of theNotes)
		end try
	end tell
end getEvernote_Info

(* 
======================================
// UTILITY SUBROUTINES 
======================================
*)

--CONVERT HTML TO PLAIN TEXT
on convert_Plaintext(noteHTML)
	set shell_Text to "echo " & (quoted form of noteHTML) & " | textutil -stdin -convert txt -stdout"
	set note_Text to do shell script shell_Text
	return note_Text
end convert_Plaintext

--CONVERT DATE TO PLAIN TEXT STRING
on convert_Date(noteCreated)
	set AppleScript's text item delimiters to ""
	set m to ((month of noteCreated) * 1)
	set d to (day of noteCreated)
	set y to (year of noteCreated)
	set t to (time string of noteCreated)
	set date_String to (m & "/" & d & "/" & y & " " & t) as string
	return date_String
end convert_Date

on convert_title_to_date(noteTitle)
	
	-- Split the note tiltle into words
	set date_elements to every word of noteTitle
	
	-- initilize the date
	set the_date to current date
	set {time of the_date, day of the_date} to {0, 1}
	--set month of the_date to (item 2 of date_elements) as integer
	
	-- year
	set yearSubstring to (get characters 1 thru 4 of (item 1 of date_elements)) as string
	set year of the_date to yearSubstring as integer
	
	-- month 
	set monthSubstring to (get characters 5 thru 6 of (item 1 of date_elements)) as string
	set month of the_date to monthSubstring as integer
	
	-- day 
	set daySubstring to (get characters 7 thru 8 of (item 1 of date_elements)) as string
	set day of the_date to daySubstring as integer
	
	--log the_date
	return the_date
	
end convert_title_to_date

(* 
======================================
// MAIN HANDLER SUBROUTINES 
======================================
*)

--MAKE ITEM IN DAY ONE
on make_DayOne(noteName, note_Date, note_Text, noteLink)
	if dayHeader is "ON" then
		--ADD A "HEADER" AND MAKE THE ENTRY
		set note_Text to (noteName & return & return & note_Text)
		set new_DayOne to "echo " & (quoted form of note_Text) & " | '/usr/local/bin/dayone' -d=\"" & note_Date & "\" new"
		do shell script new_DayOne
	else
		--MAKE THE ENTRY WITH NO "HEADER"
		set new_DayOne to "echo " & (quoted form of note_Text) & " | /usr/local/bin/dayone -d=\"" & note_Date & "\" new"
		do shell script new_DayOne
	end if
end make_DayOne