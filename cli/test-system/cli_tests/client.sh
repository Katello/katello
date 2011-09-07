#testing client commands
KEY="key_$RAND"
VALUE="val_$RAND"

test "client remember"      client remember --option="$KEY" --value="$VALUE"
test "client saved_options" client saved_options
test "client_forget"        client forget --option="$KEY"
