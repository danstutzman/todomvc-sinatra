--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: daniel; Tablespace: 
--

CREATE TABLE schema_info (
    version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.schema_info OWNER TO daniel;

--
-- Name: users; Type: TABLE; Schema: public; Owner: daniel; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.users OWNER TO daniel;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: daniel
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO daniel;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: daniel
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: daniel
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: daniel; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: daniel
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM daniel;
GRANT ALL ON SCHEMA public TO daniel;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

