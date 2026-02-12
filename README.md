TODO
  · add a confirmation screen for deleting stuff and at least one C-z for reversing the last score point (backspace)
  · some general stats for a player (same logic of entrying a blank input on the score) in a dedicated window
    · total games played
    · all score points of all tables summed?
    · most played tables
    · high score for the selected table (or should we show that on the main screen?)
  · ideas for a collaborative/non-competitive tournament scheme/mode/window are welcome!
  · remove the mobile UI?

  
a pinball score recorder and visualizer because a spreadsheet would be too easy!

if you have a keyboard, arrows cycle through the list, the item selected effects the others keys; ENTER, DELETE and BACKSPACE

when 'table' is selected
  · ENTER, brings the prompt for adding a new table, if the table already exists it gets focused
  · DELETE, removes the tables and all the players data associated with

when 'score' is selected
  · ENTER, brings the prompt for adding a score, only numbers are accepted, if the entry is blank ("") it will show the average score in 10 entries
  · BACKSPACE, deletes the last added data point
  · DELETE, removes all the points for the selected player

when 'player' is selected
  · ENTER, brings a prompt for adding a new player, if the player already exists it gets focused
  · DELETE, deletes the player and every score tied with it

buttons on the screen were meant to facilitate mobile usage... the "LOCK" button unlocks "X" (DELETE) and "REDO" (BACKSPACE) functionality
