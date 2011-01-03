#!/bin/sh

psql -t -q -p 5433 c2corg << EOF | sed -e 's/|//' -e 's/^ //' -e 's/\s\+/ /' | egrep -v '^$'

-- sommets
select 'a' || v4_id as v4, id as v5 from summits where v4_id > 0 order by v4_id;

-- sites escalade
select 'b' || v4_id as v4, id as v5 from sites where v4_type = 'area' order by v4_id;

-- secteurs escalade
select 'c' || v4_id as v4, id as v5 from sites where v4_type = 'sect' order by v4_id;

-- iti ski
select 'd' || v4_id as v4, id || '/' || culture as v5 from routes_i18n where v4_app = 'ski' order by v4_id;

-- iti alpi
select 'e' || v4_id as v4, id || '/' || culture as v5 from routes_i18n where v4_app = 'alp' order by v4_id;

-- sorties ski
select 'f' || v4_id as v4, id as v5 from outings where v4_app = 'ski' order by v4_id;

-- sorties alp
select 'g' || v4_id as v4, id as v5 from outings where v4_app = 'alp' order by v4_id;

-- photo ski
select 'h' || v4_id as v4, id as v5 from images where v4_app = 'ski' order by v4_id;

-- photo alp
select 'i' || v4_id as v4, id as v5 from images where v4_app = 'alp' order by v4_id;

-- photo esc
select 'j' || v4_id as v4, id as v5 from images where v4_app = 'esc' order by v4_id;

EOF
