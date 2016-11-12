--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE budgets (
    id integer NOT NULL,
    name character varying,
    start_date date,
    end_date date,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE budgets_id_seq OWNED BY budgets.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: remote_account_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE remote_account_types (
    id integer NOT NULL,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: remote_account_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE remote_account_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remote_account_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE remote_account_types_id_seq OWNED BY remote_account_types.id;


--
-- Name: remote_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE remote_accounts (
    id integer NOT NULL,
    title character varying,
    inverse_values boolean,
    user_credential character varying,
    remote_account_identifier character varying,
    account_id integer,
    remote_account_type_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sync_from date
);


--
-- Name: remote_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE remote_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remote_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE remote_accounts_id_seq OWNED BY remote_accounts.id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reservations (
    id integer NOT NULL,
    category_id integer,
    amount numeric(19,4),
    ignored boolean DEFAULT false,
    budget_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    recalculate boolean
);


--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reservations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reservations_id_seq OWNED BY reservations.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE transactions (
    id integer NOT NULL,
    date date,
    description character varying,
    amount numeric(19,4),
    account_id integer,
    category_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    budget_date date,
    sort double precision,
    remote_date date
);


--
-- Name: reservations_transactions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW reservations_transactions AS
 WITH reservation_transactions AS (
         SELECT t.id AS transaction_id,
            b.id AS budget_id,
            b.start_date AS budget_start_date,
            b.end_date AS budget_end_date,
            r.id AS reservation_id,
            r.category_id,
            b.user_id
           FROM ((budgets b
             JOIN reservations r ON ((b.id = r.budget_id)))
             LEFT JOIN transactions t ON (((t.budget_date >= b.start_date) AND (t.budget_date <= b.end_date) AND (t.category_id = r.category_id))))
        )
 SELECT rt.budget_id,
    rt.reservation_id,
    COALESCE(rt.transaction_id, t_2.transaction_id) AS transaction_id
   FROM (reservation_transactions rt
     LEFT JOIN ( SELECT t.id AS transaction_id,
            t.budget_date,
            c.user_id
           FROM (transactions t
             JOIN categories c ON ((t.category_id = c.id)))
          WHERE (NOT (t.id IN ( SELECT reservation_transactions.transaction_id
                   FROM reservation_transactions
                  WHERE (reservation_transactions.transaction_id IS NOT NULL))))) t_2 ON (((t_2.budget_date >= rt.budget_start_date) AND (t_2.budget_date <= rt.budget_end_date) AND (t_2.user_id = rt.user_id) AND (rt.category_id IS NULL))));


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: transaction_balances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW transaction_balances AS
 SELECT t.id AS transaction_id,
    sum(t.amount) OVER (PARTITION BY t.account_id ORDER BY t.date, t.id) AS account_balance,
    sum(t.amount) OVER (PARTITION BY a.user_id ORDER BY t.date, t.id) AS balance
   FROM ((transactions t
     JOIN accounts a ON ((t.account_id = a.id)))
     JOIN categories c ON ((t.category_id = c.id)))
  ORDER BY a.user_id, t.date, t.description, t.id;


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transactions_id_seq OWNED BY transactions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY budgets ALTER COLUMN id SET DEFAULT nextval('budgets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY remote_account_types ALTER COLUMN id SET DEFAULT nextval('remote_account_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY remote_accounts ALTER COLUMN id SET DEFAULT nextval('remote_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations ALTER COLUMN id SET DEFAULT nextval('reservations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions ALTER COLUMN id SET DEFAULT nextval('transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: remote_account_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY remote_account_types
    ADD CONSTRAINT remote_account_types_pkey PRIMARY KEY (id);


--
-- Name: remote_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY remote_accounts
    ADD CONSTRAINT remote_accounts_pkey PRIMARY KEY (id);


--
-- Name: reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_user_id ON accounts USING btree (user_id);


--
-- Name: index_budgets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_budgets_on_user_id ON budgets USING btree (user_id);


--
-- Name: index_categories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_user_id ON categories USING btree (user_id);


--
-- Name: index_remote_accounts_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remote_accounts_on_account_id ON remote_accounts USING btree (account_id);


--
-- Name: index_remote_accounts_on_remote_account_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remote_accounts_on_remote_account_type_id ON remote_accounts USING btree (remote_account_type_id);


--
-- Name: index_reservations_on_budget_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_budget_id ON reservations USING btree (budget_id);


--
-- Name: index_reservations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_category_id ON reservations USING btree (category_id);


--
-- Name: index_transactions_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_account_id ON transactions USING btree (account_id);


--
-- Name: index_transactions_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transactions_on_category_id ON transactions USING btree (category_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20131207235121');

INSERT INTO schema_migrations (version) VALUES ('20131208193009');

INSERT INTO schema_migrations (version) VALUES ('20131208195313');

INSERT INTO schema_migrations (version) VALUES ('20131220140559');

INSERT INTO schema_migrations (version) VALUES ('20140105225121');

INSERT INTO schema_migrations (version) VALUES ('20140109225452');

INSERT INTO schema_migrations (version) VALUES ('20140110115854');

INSERT INTO schema_migrations (version) VALUES ('20140508194703');

INSERT INTO schema_migrations (version) VALUES ('20140524165215');

INSERT INTO schema_migrations (version) VALUES ('20140824162350');

INSERT INTO schema_migrations (version) VALUES ('20140825164039');

INSERT INTO schema_migrations (version) VALUES ('20140825173309');

INSERT INTO schema_migrations (version) VALUES ('20150319161606');

INSERT INTO schema_migrations (version) VALUES ('20150319162610');

INSERT INTO schema_migrations (version) VALUES ('20150405144549');

INSERT INTO schema_migrations (version) VALUES ('20150405144747');

INSERT INTO schema_migrations (version) VALUES ('20150406123554');

INSERT INTO schema_migrations (version) VALUES ('20151222142139');

INSERT INTO schema_migrations (version) VALUES ('20151222151151');

INSERT INTO schema_migrations (version) VALUES ('20151222181801');

INSERT INTO schema_migrations (version) VALUES ('20151224173421');

INSERT INTO schema_migrations (version) VALUES ('20151224180444');

INSERT INTO schema_migrations (version) VALUES ('20160522152154');

INSERT INTO schema_migrations (version) VALUES ('20160522222154');

INSERT INTO schema_migrations (version) VALUES ('20160524222154');

INSERT INTO schema_migrations (version) VALUES ('20161007144155');

INSERT INTO schema_migrations (version) VALUES ('20161111205301');

