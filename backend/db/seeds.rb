puts "==> Seeding RotorShift..."

org = Organization.find_or_create_by!(code: "HEMS-01") do |o|
  o.name = "SkyRescue Operations"
  o.timezone = "Europe/Madrid"
  o.country = "ES"
end

pattern_7_7 = ShiftPattern.find_or_create_by!(organization: org, name: "Standard 7/7") do |sp|
  sp.days_on = 7
  sp.days_off = 7
end

pattern_5_2 = ShiftPattern.find_or_create_by!(organization: org, name: "Weekday 5/2") do |sp|
  sp.days_on = 5
  sp.days_off = 2
end

boss = User.find_or_create_by!(email: "boss@skyrescue.com") do |u|
  u.first_name = "Carlos"
  u.last_name = "Mendez"
  u.password = "password123"
  u.organization = org
end
boss.add_role(:admin) unless boss.has_role?(:admin)

pilot_data = [
  { first: "Ana", last: "Garcia", email: "ana@skyrescue.com", license: "ESP-H-001", pattern: pattern_7_7, start_offset: 0 },
  { first: "Miguel", last: "Torres", email: "miguel@skyrescue.com", license: "ESP-H-002", pattern: pattern_7_7, start_offset: 2 },
  { first: "Laura", last: "Ruiz", email: "laura@skyrescue.com", license: "ESP-H-003", pattern: pattern_7_7, start_offset: 4 },
  { first: "David", last: "Lopez", email: "david@skyrescue.com", license: "ESP-H-004", pattern: pattern_7_7, start_offset: 7 },
  { first: "Sofia", last: "Martin", email: "sofia@skyrescue.com", license: "ESP-H-005", pattern: pattern_7_7, start_offset: 9 },
  { first: "Pablo", last: "Sanchez", email: "pablo@skyrescue.com", license: "ESP-H-006", pattern: pattern_7_7, start_offset: 11 },
  { first: "Elena", last: "Fernandez", email: "elena@skyrescue.com", license: "ESP-H-007", pattern: pattern_7_7, start_offset: 1 },
  { first: "Javier", last: "Diaz", email: "javier@skyrescue.com", license: "ESP-H-008", pattern: pattern_7_7, start_offset: 3 },
  { first: "Carmen", last: "Moreno", email: "carmen@skyrescue.com", license: "ESP-H-009", pattern: pattern_7_7, start_offset: 5 },
  { first: "Raul", last: "Jimenez", email: "raul@skyrescue.com", license: "ESP-H-010", pattern: pattern_7_7, start_offset: 8 },
  { first: "Isabel", last: "Alvarez", email: "isabel@skyrescue.com", license: "ESP-H-011", pattern: pattern_5_2, start_offset: 0 },
  { first: "Jorge", last: "Romero", email: "jorge@skyrescue.com", license: "ESP-H-012", pattern: pattern_5_2, start_offset: 1 },
]

reference_date = Date.new(2026, 1, 1)

pilot_data.each do |pd|
  user = User.find_or_create_by!(email: pd[:email]) do |u|
    u.first_name = pd[:first]
    u.last_name = pd[:last]
    u.password = "password123"
    u.organization = org
  end

  PilotProfile.find_or_create_by!(user: user) do |pp|
    pp.shift_pattern = pd[:pattern]
    pp.license_number = pd[:license]
    pp.rotation_start_date = reference_date + pd[:start_offset].days
  end
end

Holiday.find_or_create_by!(organization: org, date: Date.new(2026, 8, 15)) do |h|
  h.name = "Assumption of Mary"
end

Holiday.find_or_create_by!(organization: org, date: Date.new(2026, 10, 12)) do |h|
  h.name = "Spanish National Day"
end

Holiday.find_or_create_by!(organization: org, date: Date.new(2026, 12, 25)) do |h|
  h.name = "Christmas Day"
end

StaffingRequirement.find_or_create_by!(organization: org, start_date: Date.new(2026, 6, 1), end_date: Date.new(2026, 8, 31)) do |sr|
  sr.minimum_pilots = 5
  sr.notes = "Summer season - increased coverage"
end

StaffingRequirement.find_or_create_by!(organization: org, start_date: Date.new(2026, 9, 1), end_date: Date.new(2026, 12, 31)) do |sr|
  sr.minimum_pilots = 3
  sr.notes = "Standard coverage"
end

puts "==> Seeded: #{Organization.count} org, #{User.count} users, #{PilotProfile.count} pilots, #{ShiftPattern.count} patterns, #{Holiday.count} holidays"
