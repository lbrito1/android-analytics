conn = ActiveRecord::Base.connection

conn.exec_query <<-SQL
--
-- Data for Name: blazer_dashboard_queries; Type: TABLE DATA; Schema: public; Owner: android_analytics
--

COPY public.blazer_dashboard_queries (id, dashboard_id, query_id, "position", created_at, updated_at) FROM stdin; \
3 1 4 0 2020-06-30 23:08:01.022309  2020-06-30 23:24:44.010583 \
1 1 3 1 2020-06-30 00:26:34.899173  2020-06-30 23:24:44.031887 \
2 1 2 2 2020-06-30 00:26:34.923882  2020-06-30 23:24:44.168245 \
\.


--
-- Data for Name: blazer_dashboards; Type: TABLE DATA; Schema: public; Owner: android_analytics
--

COPY public.blazer_dashboards (id, creator_id, name, created_at, updated_at) FROM stdin;
1 \N  my_dashboard  2020-06-30 00:26:34.812946  2020-06-30 23:08:20.021421
\.


--
-- Data for Name: blazer_queries; Type: TABLE DATA; Schema: public; Owner: android_analytics
--

COPY public.blazer_queries (id, creator_id, name, description, statement, data_source, created_at, updated_at) FROM stdin;
1 \N      select count(*) from hits;  main  2020-06-29 22:17:49.758482  2020-06-29 22:17:49.758482
2 \N  All-time visitor count    select count(*) from hits;  main  2020-06-29 23:22:58.576509  2020-06-30 00:26:51.016816
3 \N  Visitors by day   SELECT date_trunc('day', created_at), COUNT(*) FROM hits GROUP BY 1 ORDER BY 1; main  2020-06-30 00:26:05.852272  2020-06-30 23:10:10.301814
4 \N  Visitor Map   SELECT lat, long AS lng from hits;  main  2020-06-30 23:07:46.515341  2020-06-30 23:10:21.9742
\.
--

SELECT pg_catalog.setval('public.blazer_audits_id_seq', 114, true);


--
-- Name: blazer_checks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: android_analytics
--

SELECT pg_catalog.setval('public.blazer_checks_id_seq', 1, false);


--
-- Name: blazer_dashboard_queries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: android_analytics
--

SELECT pg_catalog.setval('public.blazer_dashboard_queries_id_seq', 3, true);


--
-- Name: blazer_dashboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: android_analytics
--

SELECT pg_catalog.setval('public.blazer_dashboards_id_seq', 1, true);


--
-- Name: blazer_queries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: android_analytics
--

SELECT pg_catalog.setval('public.blazer_queries_id_seq', 4, true);
SQL
