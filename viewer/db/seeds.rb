conn = ActiveRecord::Base.connection

conn.exec_query <<-SQL
  INSERT INTO public.blazer_queries (id, creator_id, name, description, statement, data_source, created_at, updated_at) VALUES (1, NULL, '', '', 'select count(*) from hits;', 'main', '2020-06-29 22:17:49.758482', '2020-06-29 22:17:49.758482');
  INSERT INTO public.blazer_queries (id, creator_id, name, description, statement, data_source, created_at, updated_at) VALUES (2, NULL, 'All-time visitor count', '', 'select count(*) from hits;', 'main', '2020-06-29 23:22:58.576509', '2020-06-30 00:26:51.016816');
  INSERT INTO public.blazer_queries (id, creator_id, name, description, statement, data_source, created_at, updated_at) VALUES (3, NULL, 'Visitors by day', '', 'SELECT date_trunc(''day'', created_at), COUNT(*) FROM hits GROUP BY 1 ORDER BY 1;', 'main', '2020-06-30 00:26:05.852272', '2020-06-30 23:10:10.301814');
  INSERT INTO public.blazer_queries (id, creator_id, name, description, statement, data_source, created_at, updated_at) VALUES (4, NULL, 'Visitor Map', '', 'SELECT lat, long AS lng from hits;', 'main', '2020-06-30 23:07:46.515341', '2020-06-30 23:10:21.9742');
SQL
