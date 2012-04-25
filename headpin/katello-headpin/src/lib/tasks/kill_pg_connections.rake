task :kill_pg_connections => :environment do
  db_name = "katello"
  sh = <<EOF
ps xa \
  | grep postgres: \
  | grep #{db_name} \
  | grep -v grep \
  | awk '{print $1}' \
  | sudo xargs kill
EOF
  puts `#{sh}`
end
