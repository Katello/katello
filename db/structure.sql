--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

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
-- Name: activation_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activation_keys (
    id integer NOT NULL,
    name character varying(255),
    description text,
    organization_id integer NOT NULL,
    environment_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    usage_limit integer DEFAULT (-1),
    content_view_id integer
);


--
-- Name: activation_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activation_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activation_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activation_keys_id_seq OWNED BY activation_keys.id;


--
-- Name: changeset_content_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_content_views (
    id integer NOT NULL,
    changeset_id integer,
    content_view_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: changeset_content_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_content_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_content_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_content_views_id_seq OWNED BY changeset_content_views.id;


--
-- Name: changeset_dependencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_dependencies (
    id integer NOT NULL,
    changeset_id integer,
    package_id character varying(255),
    display_name character varying(255),
    product_id integer NOT NULL,
    dependency_of character varying(255)
);


--
-- Name: changeset_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_dependencies_id_seq OWNED BY changeset_dependencies.id;


--
-- Name: changeset_distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_distributions (
    id integer NOT NULL,
    changeset_id integer,
    distribution_id character varying(255),
    display_name character varying(255),
    product_id integer NOT NULL
);


--
-- Name: changeset_distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_distributions_id_seq OWNED BY changeset_distributions.id;


--
-- Name: changeset_errata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_errata (
    id integer NOT NULL,
    changeset_id integer,
    errata_id character varying(255),
    display_name character varying(255),
    product_id integer NOT NULL
);


--
-- Name: changeset_errata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_errata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_errata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_errata_id_seq OWNED BY changeset_errata.id;


--
-- Name: changeset_packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_packages (
    id integer NOT NULL,
    changeset_id integer,
    package_id character varying(255),
    display_name character varying(255),
    product_id integer NOT NULL,
    nvrea character varying(255)
);


--
-- Name: changeset_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_packages_id_seq OWNED BY changeset_packages.id;


--
-- Name: changeset_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changeset_users (
    id integer NOT NULL,
    changeset_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: changeset_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changeset_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changeset_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changeset_users_id_seq OWNED BY changeset_users.id;


--
-- Name: changesets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changesets (
    id integer NOT NULL,
    environment_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    promotion_date timestamp without time zone,
    state character varying(255) DEFAULT 'new'::character varying NOT NULL,
    task_status_id integer,
    description text,
    type character varying(255) DEFAULT 'PromotionChangeset'::character varying
);


--
-- Name: changesets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE changesets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changesets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE changesets_id_seq OWNED BY changesets.id;


--
-- Name: changesets_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changesets_products (
    changeset_id integer,
    product_id integer
);


--
-- Name: changesets_repositories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE changesets_repositories (
    changeset_id integer NOT NULL,
    repository_id integer NOT NULL
);


--
-- Name: component_content_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE component_content_views (
    id integer NOT NULL,
    content_view_definition_id integer,
    content_view_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: component_content_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE component_content_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: component_content_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE component_content_views_id_seq OWNED BY component_content_views.id;


--
-- Name: content_view_definition_bases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_definition_bases (
    id integer NOT NULL,
    name character varying(255),
    label character varying(255) NOT NULL,
    description text,
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    composite boolean DEFAULT false NOT NULL,
    type character varying(255),
    source_id integer
);


--
-- Name: content_view_definition_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_definition_bases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_definition_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_definition_bases_id_seq OWNED BY content_view_definition_bases.id;


--
-- Name: content_view_definition_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_definition_products (
    id integer NOT NULL,
    content_view_definition_id integer,
    product_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_view_definition_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_definition_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_definition_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_definition_products_id_seq OWNED BY content_view_definition_products.id;


--
-- Name: content_view_definition_repositories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_definition_repositories (
    id integer NOT NULL,
    content_view_definition_id integer,
    repository_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_view_definition_repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_definition_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_definition_repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_definition_repositories_id_seq OWNED BY content_view_definition_repositories.id;


--
-- Name: content_view_environments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_environments (
    id integer NOT NULL,
    name character varying(255),
    label character varying(255) NOT NULL,
    cp_id character varying(255),
    content_view_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    environment_id integer NOT NULL
);


--
-- Name: content_view_environments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_environments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_environments_id_seq OWNED BY content_view_environments.id;


--
-- Name: content_view_version_environments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_version_environments (
    content_view_version_id integer,
    environment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id integer NOT NULL
);


--
-- Name: content_view_version_environments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_version_environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_version_environments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_version_environments_id_seq OWNED BY content_view_version_environments.id;


--
-- Name: content_view_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_view_versions (
    id integer NOT NULL,
    content_view_id integer,
    version integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    definition_archive_id integer
);


--
-- Name: content_view_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_view_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_view_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_view_versions_id_seq OWNED BY content_view_versions.id;


--
-- Name: content_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_views (
    id integer NOT NULL,
    name character varying(255),
    label character varying(255) NOT NULL,
    description text,
    content_view_definition_id integer,
    organization_id integer,
    "default" boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_views_id_seq OWNED BY content_views.id;


--
-- Name: custom_info; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_info (
    id integer NOT NULL,
    keyname character varying(255),
    value character varying(255) DEFAULT ''::character varying,
    informable_id integer,
    informable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    org_default boolean DEFAULT false
);


--
-- Name: custom_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_info_id_seq OWNED BY custom_info.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    queue character varying(255)
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
-- Name: distributors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distributors (
    id integer NOT NULL,
    uuid character varying(255),
    name character varying(255),
    description text,
    location character varying(255),
    environment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content_view_id integer
);


--
-- Name: distributors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distributors_id_seq OWNED BY distributors.id;


--
-- Name: environment_priors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE environment_priors (
    environment_id integer,
    prior_id integer NOT NULL
);


--
-- Name: environment_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE environment_products (
    id integer NOT NULL,
    environment_id integer NOT NULL,
    product_id integer NOT NULL
);


--
-- Name: environment_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE environment_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: environment_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE environment_products_id_seq OWNED BY environment_products.id;


--
-- Name: environment_system_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE environment_system_groups (
    id integer NOT NULL,
    environment_id integer,
    system_group_id integer
);


--
-- Name: environment_system_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE environment_system_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: environment_system_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE environment_system_groups_id_seq OWNED BY environment_system_groups.id;


--
-- Name: environments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE environments (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    library boolean DEFAULT false NOT NULL,
    organization_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    label character varying(255) NOT NULL
);


--
-- Name: environments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: environments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE environments_id_seq OWNED BY environments.id;


--
-- Name: filter_rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_rules (
    id integer NOT NULL,
    type character varying(255),
    parameters text,
    filter_id integer NOT NULL,
    inclusion boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: filter_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filter_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filter_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE filter_rules_id_seq OWNED BY filter_rules.id;


--
-- Name: filters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filters (
    id integer NOT NULL,
    content_view_definition_id integer,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE filters_id_seq OWNED BY filters.id;


--
-- Name: filters_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filters_products (
    filter_id integer,
    product_id integer
);


--
-- Name: filters_repositories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filters_repositories (
    filter_id integer,
    repository_id integer
);


--
-- Name: gpg_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gpg_keys (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    organization_id integer NOT NULL,
    content text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gpg_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gpg_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpg_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gpg_keys_id_seq OWNED BY gpg_keys.id;


--
-- Name: help_tips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE help_tips (
    id integer NOT NULL,
    key character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: help_tips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE help_tips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_tips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE help_tips_id_seq OWNED BY help_tips.id;


--
-- Name: job_tasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_tasks (
    id integer NOT NULL,
    job_id integer,
    task_status_id integer
);


--
-- Name: job_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_tasks_id_seq OWNED BY job_tasks.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    job_owner_id integer,
    job_owner_type character varying(255),
    pulp_id character varying(255) NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: key_pools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE key_pools (
    id integer NOT NULL,
    activation_key_id integer,
    pool_id integer
);


--
-- Name: key_pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE key_pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE key_pools_id_seq OWNED BY key_pools.id;


--
-- Name: key_system_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE key_system_groups (
    id integer NOT NULL,
    activation_key_id integer,
    system_group_id integer
);


--
-- Name: key_system_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE key_system_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_system_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE key_system_groups_id_seq OWNED BY key_system_groups.id;


--
-- Name: ldap_group_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ldap_group_roles (
    id integer NOT NULL,
    ldap_group character varying(255),
    role_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ldap_group_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ldap_group_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ldap_group_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ldap_group_roles_id_seq OWNED BY ldap_group_roles.id;


--
-- Name: marketing_engineering_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE marketing_engineering_products (
    id integer NOT NULL,
    marketing_product_id integer,
    engineering_product_id integer
);


--
-- Name: marketing_engineering_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE marketing_engineering_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketing_engineering_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE marketing_engineering_products_id_seq OWNED BY marketing_engineering_products.id;


--
-- Name: notices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notices (
    id integer NOT NULL,
    text character varying(1024) NOT NULL,
    details text,
    global boolean DEFAULT false NOT NULL,
    level character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    request_type character varying(255),
    organization_id integer
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notices_id_seq OWNED BY notices.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(255),
    description text,
    label character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deletion_task_id integer,
    default_info text,
    apply_info_task_id integer
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: organizations_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations_users (
    organization_id integer,
    user_id integer
);


--
-- Name: permission_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permission_tags (
    id integer NOT NULL,
    permission_id integer,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permission_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permission_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permission_tags_id_seq OWNED BY permission_tags.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permissions (
    id integer NOT NULL,
    role_id integer,
    resource_type_id integer,
    organization_id integer,
    all_tags boolean DEFAULT false,
    all_verbs boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255) DEFAULT ''::character varying,
    description text DEFAULT ''::character varying
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: permissions_verbs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permissions_verbs (
    permission_id integer,
    verb_id integer
);


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pools (
    id integer NOT NULL,
    cp_id character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying(255),
    description text,
    cp_id character varying(255),
    multiplier integer,
    provider_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    gpg_key_id integer,
    type character varying(255) DEFAULT 'Product'::character varying NOT NULL,
    sync_plan_id integer,
    label character varying(255) NOT NULL,
    cdn_import_success boolean DEFAULT true NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE providers (
    id integer NOT NULL,
    name character varying(255),
    description text,
    repository_url character varying(255),
    provider_type character varying(255),
    organization_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    task_status_id integer,
    discovery_url character varying(255),
    discovered_repos text,
    discovery_task_id integer
);


--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE providers_id_seq OWNED BY providers.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE repositories (
    id integer NOT NULL,
    name character varying(255),
    pulp_id character varying(255) NOT NULL,
    enabled boolean DEFAULT true,
    environment_product_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    major integer,
    minor character varying(255),
    gpg_key_id integer,
    cp_label character varying(255),
    library_instance_id integer,
    content_id character varying(255) NOT NULL,
    arch character varying(255) DEFAULT 'noarch'::character varying NOT NULL,
    label character varying(255) NOT NULL,
    content_view_version_id integer NOT NULL,
    relative_path character varying(255) NOT NULL,
    feed character varying(255),
    unprotected boolean DEFAULT false NOT NULL,
    content_type character varying(255) DEFAULT 'yum'::character varying NOT NULL
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repositories_id_seq OWNED BY repositories.id;


--
-- Name: resource_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resource_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: resource_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resource_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resource_types_id_seq OWNED BY resource_types.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    locked boolean DEFAULT false,
    type character varying(255)
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles_users (
    role_id integer,
    user_id integer,
    ldap boolean,
    id integer NOT NULL
);


--
-- Name: roles_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_users_id_seq OWNED BY roles_users.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: search_favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE search_favorites (
    id integer NOT NULL,
    params character varying(255),
    path character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: search_favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE search_favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE search_favorites_id_seq OWNED BY search_favorites.id;


--
-- Name: search_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE search_histories (
    id integer NOT NULL,
    params character varying(255),
    path character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: search_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE search_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE search_histories_id_seq OWNED BY search_histories.id;


--
-- Name: sync_plans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sync_plans (
    id integer NOT NULL,
    name character varying(255),
    description text,
    sync_date timestamp without time zone,
    "interval" character varying(255),
    organization_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sync_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sync_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sync_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sync_plans_id_seq OWNED BY sync_plans.id;


--
-- Name: system_activation_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE system_activation_keys (
    id integer NOT NULL,
    system_id integer,
    activation_key_id integer
);


--
-- Name: system_activation_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE system_activation_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_activation_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE system_activation_keys_id_seq OWNED BY system_activation_keys.id;


--
-- Name: system_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE system_groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    pulp_id character varying(255) NOT NULL,
    description text,
    max_systems integer DEFAULT (-1) NOT NULL,
    organization_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: system_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE system_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE system_groups_id_seq OWNED BY system_groups.id;


--
-- Name: system_system_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE system_system_groups (
    id integer NOT NULL,
    system_id integer,
    system_group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: system_system_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE system_system_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_system_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE system_system_groups_id_seq OWNED BY system_system_groups.id;


--
-- Name: systems; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE systems (
    id integer NOT NULL,
    uuid character varying(255),
    name character varying(255),
    description text,
    location character varying(255),
    environment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type character varying(255) DEFAULT 'System'::character varying,
    content_view_id integer
);


--
-- Name: systems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE systems_id_seq OWNED BY systems.id;


--
-- Name: task_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE task_statuses (
    id integer NOT NULL,
    type character varying(255),
    organization_id integer,
    uuid character varying(255) NOT NULL,
    state character varying(255),
    result text,
    progress text,
    start_time timestamp without time zone,
    finish_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parameters text,
    task_type character varying(255),
    user_id integer DEFAULT 0 NOT NULL,
    task_owner_id integer,
    task_owner_type character varying(255)
);


--
-- Name: task_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE task_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE task_statuses_id_seq OWNED BY task_statuses.id;


--
-- Name: user_notices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_notices (
    id integer NOT NULL,
    user_id integer,
    notice_id integer,
    viewed boolean DEFAULT false NOT NULL
);


--
-- Name: user_notices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_notices_id_seq OWNED BY user_notices.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255),
    password character varying(255),
    helptips_enabled boolean DEFAULT true,
    hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    page_size integer DEFAULT 25 NOT NULL,
    disabled boolean DEFAULT false,
    email character varying(255),
    password_reset_token character varying(255),
    password_reset_sent_at timestamp without time zone,
    preferences text,
    foreman_id integer,
    remote_id character varying(255),
    default_environment_id integer
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
-- Name: verbs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE verbs (
    id integer NOT NULL,
    verb character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: verbs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE verbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verbs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE verbs_id_seq OWNED BY verbs.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activation_keys ALTER COLUMN id SET DEFAULT nextval('activation_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_content_views ALTER COLUMN id SET DEFAULT nextval('changeset_content_views_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_dependencies ALTER COLUMN id SET DEFAULT nextval('changeset_dependencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_distributions ALTER COLUMN id SET DEFAULT nextval('changeset_distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_errata ALTER COLUMN id SET DEFAULT nextval('changeset_errata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_packages ALTER COLUMN id SET DEFAULT nextval('changeset_packages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_users ALTER COLUMN id SET DEFAULT nextval('changeset_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets ALTER COLUMN id SET DEFAULT nextval('changesets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY component_content_views ALTER COLUMN id SET DEFAULT nextval('component_content_views_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_bases ALTER COLUMN id SET DEFAULT nextval('content_view_definition_bases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_products ALTER COLUMN id SET DEFAULT nextval('content_view_definition_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_repositories ALTER COLUMN id SET DEFAULT nextval('content_view_definition_repositories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_environments ALTER COLUMN id SET DEFAULT nextval('content_view_environments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_version_environments ALTER COLUMN id SET DEFAULT nextval('content_view_version_environments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_versions ALTER COLUMN id SET DEFAULT nextval('content_view_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_views ALTER COLUMN id SET DEFAULT nextval('content_views_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_info ALTER COLUMN id SET DEFAULT nextval('custom_info_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributors ALTER COLUMN id SET DEFAULT nextval('distributors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_products ALTER COLUMN id SET DEFAULT nextval('environment_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_system_groups ALTER COLUMN id SET DEFAULT nextval('environment_system_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY environments ALTER COLUMN id SET DEFAULT nextval('environments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_rules ALTER COLUMN id SET DEFAULT nextval('filter_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters ALTER COLUMN id SET DEFAULT nextval('filters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpg_keys ALTER COLUMN id SET DEFAULT nextval('gpg_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY help_tips ALTER COLUMN id SET DEFAULT nextval('help_tips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_tasks ALTER COLUMN id SET DEFAULT nextval('job_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_pools ALTER COLUMN id SET DEFAULT nextval('key_pools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_system_groups ALTER COLUMN id SET DEFAULT nextval('key_system_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ldap_group_roles ALTER COLUMN id SET DEFAULT nextval('ldap_group_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY marketing_engineering_products ALTER COLUMN id SET DEFAULT nextval('marketing_engineering_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notices ALTER COLUMN id SET DEFAULT nextval('notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permission_tags ALTER COLUMN id SET DEFAULT nextval('permission_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers ALTER COLUMN id SET DEFAULT nextval('providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories ALTER COLUMN id SET DEFAULT nextval('repositories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_types ALTER COLUMN id SET DEFAULT nextval('resource_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles_users ALTER COLUMN id SET DEFAULT nextval('roles_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_favorites ALTER COLUMN id SET DEFAULT nextval('search_favorites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_histories ALTER COLUMN id SET DEFAULT nextval('search_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sync_plans ALTER COLUMN id SET DEFAULT nextval('sync_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_activation_keys ALTER COLUMN id SET DEFAULT nextval('system_activation_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_groups ALTER COLUMN id SET DEFAULT nextval('system_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_system_groups ALTER COLUMN id SET DEFAULT nextval('system_system_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY systems ALTER COLUMN id SET DEFAULT nextval('systems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_statuses ALTER COLUMN id SET DEFAULT nextval('task_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notices ALTER COLUMN id SET DEFAULT nextval('user_notices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY verbs ALTER COLUMN id SET DEFAULT nextval('verbs_id_seq'::regclass);


--
-- Name: activation_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activation_keys
    ADD CONSTRAINT activation_keys_pkey PRIMARY KEY (id);


--
-- Name: changeset_content_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_content_views
    ADD CONSTRAINT changeset_content_views_pkey PRIMARY KEY (id);


--
-- Name: changeset_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_dependencies
    ADD CONSTRAINT changeset_dependencies_pkey PRIMARY KEY (id);


--
-- Name: changeset_distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_distributions
    ADD CONSTRAINT changeset_distributions_pkey PRIMARY KEY (id);


--
-- Name: changeset_errata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_errata
    ADD CONSTRAINT changeset_errata_pkey PRIMARY KEY (id);


--
-- Name: changeset_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_packages
    ADD CONSTRAINT changeset_packages_pkey PRIMARY KEY (id);


--
-- Name: changeset_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changeset_users
    ADD CONSTRAINT changeset_users_pkey PRIMARY KEY (id);


--
-- Name: changesets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY changesets
    ADD CONSTRAINT changesets_pkey PRIMARY KEY (id);


--
-- Name: component_content_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY component_content_views
    ADD CONSTRAINT component_content_views_pkey PRIMARY KEY (id);


--
-- Name: content_view_definition_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_definition_products
    ADD CONSTRAINT content_view_definition_products_pkey PRIMARY KEY (id);


--
-- Name: content_view_definition_repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_definition_repositories
    ADD CONSTRAINT content_view_definition_repositories_pkey PRIMARY KEY (id);


--
-- Name: content_view_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_definition_bases
    ADD CONSTRAINT content_view_definitions_pkey PRIMARY KEY (id);


--
-- Name: content_view_environments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_environments
    ADD CONSTRAINT content_view_environments_pkey PRIMARY KEY (id);


--
-- Name: content_view_version_environments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_version_environments
    ADD CONSTRAINT content_view_version_environments_pkey PRIMARY KEY (id);


--
-- Name: content_view_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_view_versions
    ADD CONSTRAINT content_view_versions_pkey PRIMARY KEY (id);


--
-- Name: content_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_views
    ADD CONSTRAINT content_views_pkey PRIMARY KEY (id);


--
-- Name: custom_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY custom_info
    ADD CONSTRAINT custom_info_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: distributors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distributors
    ADD CONSTRAINT distributors_pkey PRIMARY KEY (id);


--
-- Name: environment_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY environment_products
    ADD CONSTRAINT environment_products_pkey PRIMARY KEY (id);


--
-- Name: environment_system_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY environment_system_groups
    ADD CONSTRAINT environment_system_groups_pkey PRIMARY KEY (id);


--
-- Name: environments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);


--
-- Name: filter_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_rules
    ADD CONSTRAINT filter_rules_pkey PRIMARY KEY (id);


--
-- Name: filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filters
    ADD CONSTRAINT filters_pkey PRIMARY KEY (id);


--
-- Name: gpg_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gpg_keys
    ADD CONSTRAINT gpg_keys_pkey PRIMARY KEY (id);


--
-- Name: help_tips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY help_tips
    ADD CONSTRAINT help_tips_pkey PRIMARY KEY (id);


--
-- Name: job_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: key_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY key_pools
    ADD CONSTRAINT key_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: key_system_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY key_system_groups
    ADD CONSTRAINT key_system_groups_pkey PRIMARY KEY (id);


--
-- Name: ldap_group_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ldap_group_roles
    ADD CONSTRAINT ldap_group_roles_pkey PRIMARY KEY (id);


--
-- Name: marketing_engineering_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY marketing_engineering_products
    ADD CONSTRAINT marketing_engineering_products_pkey PRIMARY KEY (id);


--
-- Name: notices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: permission_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permission_tags
    ADD CONSTRAINT permission_tags_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles_users
    ADD CONSTRAINT roles_users_pkey PRIMARY KEY (id);


--
-- Name: search_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY search_favorites
    ADD CONSTRAINT search_favorites_pkey PRIMARY KEY (id);


--
-- Name: search_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY search_histories
    ADD CONSTRAINT search_histories_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: sync_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sync_plans
    ADD CONSTRAINT sync_plans_pkey PRIMARY KEY (id);


--
-- Name: system_activation_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY system_activation_keys
    ADD CONSTRAINT system_activation_keys_pkey PRIMARY KEY (id);


--
-- Name: system_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY system_groups
    ADD CONSTRAINT system_groups_pkey PRIMARY KEY (id);


--
-- Name: system_system_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY system_system_groups
    ADD CONSTRAINT system_system_groups_pkey PRIMARY KEY (id);


--
-- Name: systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY systems
    ADD CONSTRAINT systems_pkey PRIMARY KEY (id);


--
-- Name: task_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY task_statuses
    ADD CONSTRAINT task_statuses_pkey PRIMARY KEY (id);


--
-- Name: user_notices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_notices
    ADD CONSTRAINT user_notices_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verbs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verbs
    ADD CONSTRAINT verbs_pkey PRIMARY KEY (id);


--
-- Name: component_content_views_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX component_content_views_index ON component_content_views USING btree (content_view_definition_id, content_view_id);


--
-- Name: content_view_def_product_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX content_view_def_product_index ON content_view_definition_products USING btree (content_view_definition_id, product_id);


--
-- Name: cvd_repo_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX cvd_repo_index ON content_view_definition_repositories USING btree (content_view_definition_id, repository_id);


--
-- Name: cvv_cv_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX cvv_cv_index ON content_view_versions USING btree (id, content_view_id);


--
-- Name: cvv_env_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cvv_env_index ON content_view_version_environments USING btree (content_view_version_id, environment_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_activation_keys_on_content_view_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activation_keys_on_content_view_id ON activation_keys USING btree (content_view_id);


--
-- Name: index_activation_keys_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activation_keys_on_environment_id ON activation_keys USING btree (environment_id);


--
-- Name: index_activation_keys_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_activation_keys_on_name_and_organization_id ON activation_keys USING btree (name, organization_id);


--
-- Name: index_activation_keys_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activation_keys_on_organization_id ON activation_keys USING btree (organization_id);


--
-- Name: index_activation_keys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activation_keys_on_user_id ON activation_keys USING btree (user_id);


--
-- Name: index_changeset_dependencies_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_dependencies_on_changeset_id ON changeset_dependencies USING btree (changeset_id);


--
-- Name: index_changeset_dependencies_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_dependencies_on_package_id ON changeset_dependencies USING btree (package_id);


--
-- Name: index_changeset_dependencies_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_dependencies_on_product_id ON changeset_dependencies USING btree (product_id);


--
-- Name: index_changeset_distributions_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_distributions_on_changeset_id ON changeset_distributions USING btree (changeset_id);


--
-- Name: index_changeset_distributions_on_distribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_distributions_on_distribution_id ON changeset_distributions USING btree (distribution_id);


--
-- Name: index_changeset_distributions_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_distributions_on_product_id ON changeset_distributions USING btree (product_id);


--
-- Name: index_changeset_errata_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_errata_on_changeset_id ON changeset_errata USING btree (changeset_id);


--
-- Name: index_changeset_errata_on_errata_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_errata_on_errata_id ON changeset_errata USING btree (errata_id);


--
-- Name: index_changeset_errata_on_errata_id_and_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_changeset_errata_on_errata_id_and_changeset_id ON changeset_errata USING btree (errata_id, changeset_id);


--
-- Name: index_changeset_errata_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_errata_on_product_id ON changeset_errata USING btree (product_id);


--
-- Name: index_changeset_packages_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_packages_on_changeset_id ON changeset_packages USING btree (changeset_id);


--
-- Name: index_changeset_packages_on_nvrea_and_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_changeset_packages_on_nvrea_and_changeset_id ON changeset_packages USING btree (nvrea, changeset_id);


--
-- Name: index_changeset_packages_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_packages_on_package_id ON changeset_packages USING btree (package_id);


--
-- Name: index_changeset_packages_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_packages_on_product_id ON changeset_packages USING btree (product_id);


--
-- Name: index_changeset_users_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_users_on_changeset_id ON changeset_users USING btree (changeset_id);


--
-- Name: index_changeset_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changeset_users_on_user_id ON changeset_users USING btree (user_id);


--
-- Name: index_changesets_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_on_environment_id ON changesets USING btree (environment_id);


--
-- Name: index_changesets_on_name_and_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_changesets_on_name_and_environment_id ON changesets USING btree (name, environment_id);


--
-- Name: index_changesets_on_task_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_on_task_status_id ON changesets USING btree (task_status_id);


--
-- Name: index_changesets_products_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_products_on_changeset_id ON changesets_products USING btree (changeset_id);


--
-- Name: index_changesets_products_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_products_on_product_id ON changesets_products USING btree (product_id);


--
-- Name: index_changesets_repositories_on_changeset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_repositories_on_changeset_id ON changesets_repositories USING btree (changeset_id);


--
-- Name: index_changesets_repositories_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_changesets_repositories_on_repository_id ON changesets_repositories USING btree (repository_id);


--
-- Name: index_content_view_definitions_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_view_definitions_on_name_and_organization_id ON content_view_definition_bases USING btree (name, organization_id);


--
-- Name: index_content_view_environments_on_content_view_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_view_environments_on_content_view_id ON content_view_environments USING btree (content_view_id);


--
-- Name: index_content_view_environments_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_view_environments_on_environment_id ON content_view_environments USING btree (environment_id);


--
-- Name: index_content_views_on_content_view_definition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_views_on_content_view_definition_id ON content_views USING btree (content_view_definition_id);


--
-- Name: index_content_views_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_views_on_name_and_organization_id ON content_views USING btree (name, organization_id);


--
-- Name: index_content_views_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_views_on_organization_id ON content_views USING btree (organization_id);


--
-- Name: index_content_views_on_organization_id_and_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_content_views_on_organization_id_and_label ON content_views USING btree (organization_id, label);


--
-- Name: index_cs_distro_distro_id_cs_id_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cs_distro_distro_id_cs_id_p_id ON changeset_distributions USING btree (distribution_id, changeset_id, product_id);


--
-- Name: index_custom_info_on_type_id_keyname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_custom_info_on_type_id_keyname ON custom_info USING btree (informable_type, informable_id, keyname);


--
-- Name: index_cve_cp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cve_cp_id ON content_view_environments USING btree (cp_id);


--
-- Name: index_cve_eid_cv_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cve_eid_cv_id ON content_view_environments USING btree (environment_id, content_view_id);


--
-- Name: index_distributors_on_content_view_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_distributors_on_content_view_id ON distributors USING btree (content_view_id);


--
-- Name: index_distributors_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_distributors_on_environment_id ON distributors USING btree (environment_id);


--
-- Name: index_environment_priors_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_environment_priors_on_environment_id ON environment_priors USING btree (environment_id);


--
-- Name: index_environment_priors_on_prior_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_environment_priors_on_prior_id ON environment_priors USING btree (prior_id);


--
-- Name: index_environment_products_on_environment_id_and_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_environment_products_on_environment_id_and_product_id ON environment_products USING btree (environment_id, product_id);


--
-- Name: index_environment_system_groups_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_environment_system_groups_on_environment_id ON environment_system_groups USING btree (environment_id);


--
-- Name: index_environment_system_groups_on_system_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_environment_system_groups_on_system_group_id ON environment_system_groups USING btree (system_group_id);


--
-- Name: index_environments_on_label_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_environments_on_label_and_organization_id ON environments USING btree (label, organization_id);


--
-- Name: index_environments_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_environments_on_name_and_organization_id ON environments USING btree (name, organization_id);


--
-- Name: index_environments_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_environments_on_organization_id ON environments USING btree (organization_id);


--
-- Name: index_filter_rules_on_filter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_rules_on_filter_id ON filter_rules USING btree (filter_id);


--
-- Name: index_filters_on_content_view_definition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filters_on_content_view_definition_id ON filters USING btree (content_view_definition_id);


--
-- Name: index_filters_on_name_and_content_view_definition_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_filters_on_name_and_content_view_definition_id ON filters USING btree (name, content_view_definition_id);


--
-- Name: index_filters_products_on_filter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filters_products_on_filter_id ON filters_products USING btree (filter_id);


--
-- Name: index_filters_products_on_filter_id_and_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_filters_products_on_filter_id_and_product_id ON filters_products USING btree (filter_id, product_id);


--
-- Name: index_filters_products_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filters_products_on_product_id ON filters_products USING btree (product_id);


--
-- Name: index_filters_repositories_on_filter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filters_repositories_on_filter_id ON filters_repositories USING btree (filter_id);


--
-- Name: index_filters_repositories_on_filter_id_and_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_filters_repositories_on_filter_id_and_repository_id ON filters_repositories USING btree (filter_id, repository_id);


--
-- Name: index_filters_repositories_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filters_repositories_on_repository_id ON filters_repositories USING btree (repository_id);


--
-- Name: index_gpg_keys_on_organization_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_gpg_keys_on_organization_id_and_name ON gpg_keys USING btree (organization_id, name);


--
-- Name: index_help_tips_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_help_tips_on_user_id ON help_tips USING btree (user_id);


--
-- Name: index_job_tasks_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_tasks_on_job_id ON job_tasks USING btree (job_id);


--
-- Name: index_job_tasks_on_task_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_job_tasks_on_task_status_id ON job_tasks USING btree (task_status_id);


--
-- Name: index_jobs_on_job_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_job_owner_id ON jobs USING btree (job_owner_id);


--
-- Name: index_jobs_on_pulp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_pulp_id ON jobs USING btree (pulp_id);


--
-- Name: index_key_pools_on_activation_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_key_pools_on_activation_key_id ON key_pools USING btree (activation_key_id);


--
-- Name: index_key_pools_on_pool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_key_pools_on_pool_id ON key_pools USING btree (pool_id);


--
-- Name: index_key_system_groups_on_activation_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_key_system_groups_on_activation_key_id ON key_system_groups USING btree (activation_key_id);


--
-- Name: index_key_system_groups_on_system_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_key_system_groups_on_system_group_id ON key_system_groups USING btree (system_group_id);


--
-- Name: index_ldap_group_roles_on_ldap_group_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_ldap_group_roles_on_ldap_group_and_role_id ON ldap_group_roles USING btree (ldap_group, role_id);


--
-- Name: index_ldap_group_roles_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ldap_group_roles_on_role_id ON ldap_group_roles USING btree (role_id);


--
-- Name: index_marketing_engineering_products_on_engineering_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_marketing_engineering_products_on_engineering_product_id ON marketing_engineering_products USING btree (engineering_product_id);


--
-- Name: index_marketing_engineering_products_on_marketing_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_marketing_engineering_products_on_marketing_product_id ON marketing_engineering_products USING btree (marketing_product_id);


--
-- Name: index_notices_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notices_on_organization_id ON notices USING btree (organization_id);


--
-- Name: index_organizations_on_cp_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_cp_key ON organizations USING btree (label);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (name);


--
-- Name: index_organizations_on_task_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organizations_on_task_id ON organizations USING btree (deletion_task_id);


--
-- Name: index_organizations_users_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organizations_users_on_organization_id ON organizations_users USING btree (organization_id);


--
-- Name: index_organizations_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_organizations_users_on_user_id ON organizations_users USING btree (user_id);


--
-- Name: index_permission_tags_on_permission_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permission_tags_on_permission_id ON permission_tags USING btree (permission_id);


--
-- Name: index_permission_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permission_tags_on_tag_id ON permission_tags USING btree (tag_id);


--
-- Name: index_permissions_on_name_and_organization_id_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_permissions_on_name_and_organization_id_and_role_id ON permissions USING btree (name, organization_id, role_id);


--
-- Name: index_permissions_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_on_organization_id ON permissions USING btree (organization_id);


--
-- Name: index_permissions_on_resource_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_on_resource_type_id ON permissions USING btree (resource_type_id);


--
-- Name: index_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_on_role_id ON permissions USING btree (role_id);


--
-- Name: index_permissions_verbs_on_permission_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_verbs_on_permission_id ON permissions_verbs USING btree (permission_id);


--
-- Name: index_permissions_verbs_on_verb_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_verbs_on_verb_id ON permissions_verbs USING btree (verb_id);


--
-- Name: index_pools_on_cp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pools_on_cp_id ON pools USING btree (cp_id);


--
-- Name: index_products_on_cp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_cp_id ON products USING btree (cp_id);


--
-- Name: index_products_on_gpg_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_gpg_key_id ON products USING btree (gpg_key_id);


--
-- Name: index_products_on_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_provider_id ON products USING btree (provider_id);


--
-- Name: index_products_on_sync_plan_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_products_on_sync_plan_id ON products USING btree (sync_plan_id);


--
-- Name: index_providers_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_providers_on_name_and_organization_id ON providers USING btree (name, organization_id);


--
-- Name: index_providers_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_providers_on_organization_id ON providers USING btree (organization_id);


--
-- Name: index_providers_on_task_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_providers_on_task_status_id ON providers USING btree (task_status_id);


--
-- Name: index_repositories_on_content_view_version_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_content_view_version_id ON repositories USING btree (content_view_version_id);


--
-- Name: index_repositories_on_cp_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_cp_label ON repositories USING btree (cp_label);


--
-- Name: index_repositories_on_environment_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_environment_product_id ON repositories USING btree (environment_product_id);


--
-- Name: index_repositories_on_gpg_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_gpg_key_id ON repositories USING btree (gpg_key_id);


--
-- Name: index_repositories_on_library_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_library_instance_id ON repositories USING btree (library_instance_id);


--
-- Name: index_repositories_on_pulp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_repositories_on_pulp_id ON repositories USING btree (pulp_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_users_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_role_id ON roles_users USING btree (role_id);


--
-- Name: index_roles_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_user_id ON roles_users USING btree (user_id);


--
-- Name: index_roles_users_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_roles_users_on_user_id_and_role_id ON roles_users USING btree (user_id, role_id);


--
-- Name: index_search_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_search_favorites_on_user_id ON search_favorites USING btree (user_id);


--
-- Name: index_search_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_search_histories_on_user_id ON search_histories USING btree (user_id);


--
-- Name: index_sync_plans_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sync_plans_on_name_and_organization_id ON sync_plans USING btree (name, organization_id);


--
-- Name: index_sync_plans_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sync_plans_on_organization_id ON sync_plans USING btree (organization_id);


--
-- Name: index_system_activation_keys_on_activation_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_activation_keys_on_activation_key_id ON system_activation_keys USING btree (activation_key_id);


--
-- Name: index_system_activation_keys_on_system_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_activation_keys_on_system_id ON system_activation_keys USING btree (system_id);


--
-- Name: index_system_groups_on_name_and_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_system_groups_on_name_and_organization_id ON system_groups USING btree (name, organization_id);


--
-- Name: index_system_groups_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_groups_on_organization_id ON system_groups USING btree (organization_id);


--
-- Name: index_system_groups_on_pulp_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_groups_on_pulp_id ON system_groups USING btree (pulp_id);


--
-- Name: index_system_system_groups_on_system_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_system_groups_on_system_group_id ON system_system_groups USING btree (system_group_id);


--
-- Name: index_system_system_groups_on_system_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_system_system_groups_on_system_id ON system_system_groups USING btree (system_id);


--
-- Name: index_systems_on_content_view_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_systems_on_content_view_id ON systems USING btree (content_view_id);


--
-- Name: index_systems_on_environment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_systems_on_environment_id ON systems USING btree (environment_id);


--
-- Name: index_task_statuses_on_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_task_statuses_on_organization_id ON task_statuses USING btree (organization_id);


--
-- Name: index_task_statuses_on_task_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_task_statuses_on_task_owner_id ON task_statuses USING btree (task_owner_id);


--
-- Name: index_task_statuses_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_task_statuses_on_user_id ON task_statuses USING btree (user_id);


--
-- Name: index_task_statuses_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_task_statuses_on_uuid ON task_statuses USING btree (uuid);


--
-- Name: index_user_notices_on_notice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_notices_on_notice_id ON user_notices USING btree (notice_id);


--
-- Name: index_user_notices_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_notices_on_user_id ON user_notices USING btree (user_id);


--
-- Name: index_users_on_remote_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_remote_id ON users USING btree (remote_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: repositories_l_cvvi_epi; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX repositories_l_cvvi_epi ON repositories USING btree (label, content_view_version_id, environment_product_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: CV_definition_repositories_CV_definition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_repositories
    ADD CONSTRAINT "CV_definition_repositories_CV_definition_id_fk" FOREIGN KEY (content_view_definition_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activation_keys_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activation_keys
    ADD CONSTRAINT activation_keys_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activation_keys_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activation_keys
    ADD CONSTRAINT activation_keys_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activation_keys_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activation_keys
    ADD CONSTRAINT activation_keys_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: activation_keys_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY activation_keys
    ADD CONSTRAINT activation_keys_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_content_views_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_content_views
    ADD CONSTRAINT changeset_content_views_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_content_views_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_content_views
    ADD CONSTRAINT changeset_content_views_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_dependencies_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_dependencies
    ADD CONSTRAINT changeset_dependencies_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_dependencies_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_dependencies
    ADD CONSTRAINT changeset_dependencies_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_distributions_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_distributions
    ADD CONSTRAINT changeset_distributions_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_distributions_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_distributions
    ADD CONSTRAINT changeset_distributions_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_errata_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_errata
    ADD CONSTRAINT changeset_errata_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_errata_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_errata
    ADD CONSTRAINT changeset_errata_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_packages_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_packages
    ADD CONSTRAINT changeset_packages_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_packages_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_packages
    ADD CONSTRAINT changeset_packages_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_users_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_users
    ADD CONSTRAINT changeset_users_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changeset_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changeset_users
    ADD CONSTRAINT changeset_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets
    ADD CONSTRAINT changesets_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_products_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets_products
    ADD CONSTRAINT changesets_products_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_products_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets_products
    ADD CONSTRAINT changesets_products_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_repositories_changeset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets_repositories
    ADD CONSTRAINT changesets_repositories_changeset_id_fk FOREIGN KEY (changeset_id) REFERENCES changesets(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_repositories_repository_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets_repositories
    ADD CONSTRAINT changesets_repositories_repository_id_fk FOREIGN KEY (repository_id) REFERENCES repositories(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: changesets_task_status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY changesets
    ADD CONSTRAINT changesets_task_status_id_fk FOREIGN KEY (task_status_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: component_content_views_content_view_definition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY component_content_views
    ADD CONSTRAINT component_content_views_content_view_definition_id_fk FOREIGN KEY (content_view_definition_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: component_content_views_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY component_content_views
    ADD CONSTRAINT component_content_views_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_definition_bases_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_bases
    ADD CONSTRAINT content_view_definition_bases_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_definition_bases_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_bases
    ADD CONSTRAINT content_view_definition_bases_source_id_fk FOREIGN KEY (source_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_definition_products_content_view_definition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_products
    ADD CONSTRAINT content_view_definition_products_content_view_definition_id_fk FOREIGN KEY (content_view_definition_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_definition_products_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_products
    ADD CONSTRAINT content_view_definition_products_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_definition_repositories_repository_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_definition_repositories
    ADD CONSTRAINT content_view_definition_repositories_repository_id_fk FOREIGN KEY (repository_id) REFERENCES repositories(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_environments_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_environments
    ADD CONSTRAINT content_view_environments_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_environments_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_environments
    ADD CONSTRAINT content_view_environments_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_version_environments_content_view_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_version_environments
    ADD CONSTRAINT content_view_version_environments_content_view_version_id_fk FOREIGN KEY (content_view_version_id) REFERENCES content_view_versions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_version_environments_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_version_environments
    ADD CONSTRAINT content_view_version_environments_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_versions_content_view_definition_archive_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_versions
    ADD CONSTRAINT content_view_versions_content_view_definition_archive_id_fk FOREIGN KEY (definition_archive_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_versions_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_versions
    ADD CONSTRAINT content_view_versions_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_view_versions_definition_archive_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_view_versions
    ADD CONSTRAINT content_view_versions_definition_archive_id_fk FOREIGN KEY (definition_archive_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_views_content_view_definition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_views
    ADD CONSTRAINT content_views_content_view_definition_id_fk FOREIGN KEY (content_view_definition_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_views_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_views
    ADD CONSTRAINT content_views_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: distributors_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributors
    ADD CONSTRAINT distributors_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: distributors_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributors
    ADD CONSTRAINT distributors_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_priors_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_priors
    ADD CONSTRAINT environment_priors_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_priors_prior_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_priors
    ADD CONSTRAINT environment_priors_prior_id_fk FOREIGN KEY (prior_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_products_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_products
    ADD CONSTRAINT environment_products_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_products_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_products
    ADD CONSTRAINT environment_products_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_system_groups_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_system_groups
    ADD CONSTRAINT environment_system_groups_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environment_system_groups_system_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environment_system_groups
    ADD CONSTRAINT environment_system_groups_system_group_id_fk FOREIGN KEY (system_group_id) REFERENCES system_groups(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: environments_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY environments
    ADD CONSTRAINT environments_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_content_view_definition_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters
    ADD CONSTRAINT filters_content_view_definition_id_fk FOREIGN KEY (content_view_definition_id) REFERENCES content_view_definition_bases(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_product_filter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters_products
    ADD CONSTRAINT filters_product_filter_id_fk FOREIGN KEY (filter_id) REFERENCES filters(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_product_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters_products
    ADD CONSTRAINT filters_product_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_repositories_filter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters_repositories
    ADD CONSTRAINT filters_repositories_filter_id_fk FOREIGN KEY (filter_id) REFERENCES filters(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_repositories_repository_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filters_repositories
    ADD CONSTRAINT filters_repositories_repository_id_fk FOREIGN KEY (repository_id) REFERENCES repositories(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: filters_rules_filter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_rules
    ADD CONSTRAINT filters_rules_filter_id_fk FOREIGN KEY (filter_id) REFERENCES filters(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: gpg_keys_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gpg_keys
    ADD CONSTRAINT gpg_keys_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: help_tips_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY help_tips
    ADD CONSTRAINT help_tips_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: job_tasks_job_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_job_id_fk FOREIGN KEY (job_id) REFERENCES jobs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: job_tasks_task_status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_tasks
    ADD CONSTRAINT job_tasks_task_status_id_fk FOREIGN KEY (task_status_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: key_pools_activation_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_pools
    ADD CONSTRAINT key_pools_activation_key_id_fk FOREIGN KEY (activation_key_id) REFERENCES activation_keys(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: key_pools_pool_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_pools
    ADD CONSTRAINT key_pools_pool_id_fk FOREIGN KEY (pool_id) REFERENCES pools(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: key_system_groups_activation_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_system_groups
    ADD CONSTRAINT key_system_groups_activation_key_id_fk FOREIGN KEY (activation_key_id) REFERENCES activation_keys(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: key_system_groups_system_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_system_groups
    ADD CONSTRAINT key_system_groups_system_group_id_fk FOREIGN KEY (system_group_id) REFERENCES system_groups(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: ldap_group_roles_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ldap_group_roles
    ADD CONSTRAINT ldap_group_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: marketing_engineering_products_engineering_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY marketing_engineering_products
    ADD CONSTRAINT marketing_engineering_products_engineering_product_id_fk FOREIGN KEY (engineering_product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: marketing_engineering_products_marketing_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY marketing_engineering_products
    ADD CONSTRAINT marketing_engineering_products_marketing_product_id_fk FOREIGN KEY (marketing_product_id) REFERENCES products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: notices_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notices
    ADD CONSTRAINT notices_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organizations_apply_info_task_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_apply_info_task_id_fk FOREIGN KEY (apply_info_task_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organizations_deletion_task_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_deletion_task_id_fk FOREIGN KEY (deletion_task_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organizations_users_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations_users
    ADD CONSTRAINT organizations_users_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organizations_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations_users
    ADD CONSTRAINT organizations_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permission_tags_permission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permission_tags
    ADD CONSTRAINT permission_tags_permission_id_fk FOREIGN KEY (permission_id) REFERENCES permissions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permissions_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permissions_resource_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_resource_type_id_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permissions_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permissions_verbs_permission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions_verbs
    ADD CONSTRAINT permissions_verbs_permission_id_fk FOREIGN KEY (permission_id) REFERENCES permissions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: permissions_verbs_verb_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions_verbs
    ADD CONSTRAINT permissions_verbs_verb_id_fk FOREIGN KEY (verb_id) REFERENCES verbs(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: products_gpg_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_gpg_key_id_fk FOREIGN KEY (gpg_key_id) REFERENCES gpg_keys(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: products_provider_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_provider_id_fk FOREIGN KEY (provider_id) REFERENCES providers(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: products_sync_plan_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_sync_plan_id_fk FOREIGN KEY (sync_plan_id) REFERENCES sync_plans(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: providers_discovery_task_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_discovery_task_id_fk FOREIGN KEY (discovery_task_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: providers_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: providers_task_status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY providers
    ADD CONSTRAINT providers_task_status_id_fk FOREIGN KEY (task_status_id) REFERENCES task_statuses(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: repositories_content_view_version_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_content_view_version_id_fk FOREIGN KEY (content_view_version_id) REFERENCES content_view_versions(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: repositories_environment_product_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_environment_product_id_fk FOREIGN KEY (environment_product_id) REFERENCES environment_products(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: repositories_gpg_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_gpg_key_id_fk FOREIGN KEY (gpg_key_id) REFERENCES gpg_keys(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: repositories_library_instance_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_library_instance_id_fk FOREIGN KEY (library_instance_id) REFERENCES repositories(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: roles_users_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles_users
    ADD CONSTRAINT roles_users_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: roles_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles_users
    ADD CONSTRAINT roles_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: search_favorites_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_favorites
    ADD CONSTRAINT search_favorites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: search_histories_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY search_histories
    ADD CONSTRAINT search_histories_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sync_plans_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sync_plans
    ADD CONSTRAINT sync_plans_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: system_activation_keys_activation_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_activation_keys
    ADD CONSTRAINT system_activation_keys_activation_key_id_fk FOREIGN KEY (activation_key_id) REFERENCES activation_keys(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: system_activation_keys_system_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_activation_keys
    ADD CONSTRAINT system_activation_keys_system_id_fk FOREIGN KEY (system_id) REFERENCES systems(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: system_groups_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_groups
    ADD CONSTRAINT system_groups_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: system_system_groups_system_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_system_groups
    ADD CONSTRAINT system_system_groups_system_group_id_fk FOREIGN KEY (system_group_id) REFERENCES system_groups(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: system_system_groups_system_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY system_system_groups
    ADD CONSTRAINT system_system_groups_system_id_fk FOREIGN KEY (system_id) REFERENCES systems(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: systems_content_view_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY systems
    ADD CONSTRAINT systems_content_view_id_fk FOREIGN KEY (content_view_id) REFERENCES content_views(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: systems_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY systems
    ADD CONSTRAINT systems_environment_id_fk FOREIGN KEY (environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: task_statuses_organization_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_statuses
    ADD CONSTRAINT task_statuses_organization_id_fk FOREIGN KEY (organization_id) REFERENCES organizations(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: task_statuses_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY task_statuses
    ADD CONSTRAINT task_statuses_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_notices_notice_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notices
    ADD CONSTRAINT user_notices_notice_id_fk FOREIGN KEY (notice_id) REFERENCES notices(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_notices_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notices
    ADD CONSTRAINT user_notices_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_default_environment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_default_environment_id_fk FOREIGN KEY (default_environment_id) REFERENCES environments(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110216102335');

INSERT INTO schema_migrations (version) VALUES ('20110216105056');

INSERT INTO schema_migrations (version) VALUES ('20110216171120');

INSERT INTO schema_migrations (version) VALUES ('20110303031905');

INSERT INTO schema_migrations (version) VALUES ('20110303032320');

INSERT INTO schema_migrations (version) VALUES ('20110303154949');

INSERT INTO schema_migrations (version) VALUES ('20110303161104');

INSERT INTO schema_migrations (version) VALUES ('20110304121337');

INSERT INTO schema_migrations (version) VALUES ('20110304121603');

INSERT INTO schema_migrations (version) VALUES ('20110304121750');

INSERT INTO schema_migrations (version) VALUES ('20110304121831');

INSERT INTO schema_migrations (version) VALUES ('20110304123436');

INSERT INTO schema_migrations (version) VALUES ('20110307082628');

INSERT INTO schema_migrations (version) VALUES ('20110307082853');

INSERT INTO schema_migrations (version) VALUES ('20110307090341');

INSERT INTO schema_migrations (version) VALUES ('20110308164810');

INSERT INTO schema_migrations (version) VALUES ('20110325212617');

INSERT INTO schema_migrations (version) VALUES ('20110331084953');

INSERT INTO schema_migrations (version) VALUES ('20110405175601');

INSERT INTO schema_migrations (version) VALUES ('20110414142344');

INSERT INTO schema_migrations (version) VALUES ('20110427180336');

INSERT INTO schema_migrations (version) VALUES ('20110429140623');

INSERT INTO schema_migrations (version) VALUES ('20110506182638');

INSERT INTO schema_migrations (version) VALUES ('20110517193547');

INSERT INTO schema_migrations (version) VALUES ('20110525133106');

INSERT INTO schema_migrations (version) VALUES ('20110527155402');

INSERT INTO schema_migrations (version) VALUES ('20110527155434');

INSERT INTO schema_migrations (version) VALUES ('20110602143210');

INSERT INTO schema_migrations (version) VALUES ('20110609190603');

INSERT INTO schema_migrations (version) VALUES ('20110610124916');

INSERT INTO schema_migrations (version) VALUES ('20110620205908');

INSERT INTO schema_migrations (version) VALUES ('20110627093512');

INSERT INTO schema_migrations (version) VALUES ('20110628125401');

INSERT INTO schema_migrations (version) VALUES ('20110701090248');

INSERT INTO schema_migrations (version) VALUES ('20110701091307');

INSERT INTO schema_migrations (version) VALUES ('20110707130936');

INSERT INTO schema_migrations (version) VALUES ('20110711195621');

INSERT INTO schema_migrations (version) VALUES ('20110718174042');

INSERT INTO schema_migrations (version) VALUES ('20110721205017');

INSERT INTO schema_migrations (version) VALUES ('20110726215349');

INSERT INTO schema_migrations (version) VALUES ('20110801140724');

INSERT INTO schema_migrations (version) VALUES ('20110809084121');

INSERT INTO schema_migrations (version) VALUES ('20110809151901');

INSERT INTO schema_migrations (version) VALUES ('20110810083517');

INSERT INTO schema_migrations (version) VALUES ('20110810171323');

INSERT INTO schema_migrations (version) VALUES ('20110811201230');

INSERT INTO schema_migrations (version) VALUES ('20110902182010');

INSERT INTO schema_migrations (version) VALUES ('20110916101622');

INSERT INTO schema_migrations (version) VALUES ('20110916201804');

INSERT INTO schema_migrations (version) VALUES ('20110921092208');

INSERT INTO schema_migrations (version) VALUES ('20110921092529');

INSERT INTO schema_migrations (version) VALUES ('20110921093925');

INSERT INTO schema_migrations (version) VALUES ('20110921103810');

INSERT INTO schema_migrations (version) VALUES ('20110930150236');

INSERT INTO schema_migrations (version) VALUES ('20110930150307');

INSERT INTO schema_migrations (version) VALUES ('20110930150406');

INSERT INTO schema_migrations (version) VALUES ('20111021145756');

INSERT INTO schema_migrations (version) VALUES ('20111024153541');

INSERT INTO schema_migrations (version) VALUES ('20111026133825');

INSERT INTO schema_migrations (version) VALUES ('20111101151057');

INSERT INTO schema_migrations (version) VALUES ('20111102134448');

INSERT INTO schema_migrations (version) VALUES ('20111103132929');

INSERT INTO schema_migrations (version) VALUES ('20111108212248');

INSERT INTO schema_migrations (version) VALUES ('20111110143129');

INSERT INTO schema_migrations (version) VALUES ('20111111141238');

INSERT INTO schema_migrations (version) VALUES ('20111115211120');

INSERT INTO schema_migrations (version) VALUES ('20111116012114');

INSERT INTO schema_migrations (version) VALUES ('20111116171212');

INSERT INTO schema_migrations (version) VALUES ('20111119011720');

INSERT INTO schema_migrations (version) VALUES ('20111129194031');

INSERT INTO schema_migrations (version) VALUES ('20111206011001');

INSERT INTO schema_migrations (version) VALUES ('20111206014338');

INSERT INTO schema_migrations (version) VALUES ('20111207232931');

INSERT INTO schema_migrations (version) VALUES ('20111208225553');

INSERT INTO schema_migrations (version) VALUES ('20111213100900');

INSERT INTO schema_migrations (version) VALUES ('20111213101134');

INSERT INTO schema_migrations (version) VALUES ('20111214215838');

INSERT INTO schema_migrations (version) VALUES ('20111222120322');

INSERT INTO schema_migrations (version) VALUES ('20120110014829');

INSERT INTO schema_migrations (version) VALUES ('20120115120132');

INSERT INTO schema_migrations (version) VALUES ('20120125165742');

INSERT INTO schema_migrations (version) VALUES ('20120203090936');

INSERT INTO schema_migrations (version) VALUES ('20120206090837');

INSERT INTO schema_migrations (version) VALUES ('20120207210625');

INSERT INTO schema_migrations (version) VALUES ('20120402205310');

INSERT INTO schema_migrations (version) VALUES ('20120404000648');

INSERT INTO schema_migrations (version) VALUES ('20120412160642');

INSERT INTO schema_migrations (version) VALUES ('20120416171227');

INSERT INTO schema_migrations (version) VALUES ('20120417211822');

INSERT INTO schema_migrations (version) VALUES ('20120418190120');

INSERT INTO schema_migrations (version) VALUES ('20120420003530');

INSERT INTO schema_migrations (version) VALUES ('20120502130046');

INSERT INTO schema_migrations (version) VALUES ('20120514144004');

INSERT INTO schema_migrations (version) VALUES ('20120515133827');

INSERT INTO schema_migrations (version) VALUES ('20120524105945');

INSERT INTO schema_migrations (version) VALUES ('20120605174313');

INSERT INTO schema_migrations (version) VALUES ('20120612083505');

INSERT INTO schema_migrations (version) VALUES ('20120702175532');

INSERT INTO schema_migrations (version) VALUES ('20120703185307');

INSERT INTO schema_migrations (version) VALUES ('20120724192921');

INSERT INTO schema_migrations (version) VALUES ('20120808134658');

INSERT INTO schema_migrations (version) VALUES ('20120814142910');

INSERT INTO schema_migrations (version) VALUES ('20120814142911');

INSERT INTO schema_migrations (version) VALUES ('20120815145728');

INSERT INTO schema_migrations (version) VALUES ('20120820145108');

INSERT INTO schema_migrations (version) VALUES ('20120820203952');

INSERT INTO schema_migrations (version) VALUES ('20120822205849');

INSERT INTO schema_migrations (version) VALUES ('20120831100126');

INSERT INTO schema_migrations (version) VALUES ('20120911182817');

INSERT INTO schema_migrations (version) VALUES ('20120911182838');

INSERT INTO schema_migrations (version) VALUES ('20120911182916');

INSERT INTO schema_migrations (version) VALUES ('20120912200417');

INSERT INTO schema_migrations (version) VALUES ('20120924211134');

INSERT INTO schema_migrations (version) VALUES ('20121002154742');

INSERT INTO schema_migrations (version) VALUES ('20121002154743');

INSERT INTO schema_migrations (version) VALUES ('20121002164534');

INSERT INTO schema_migrations (version) VALUES ('20121008143202');

INSERT INTO schema_migrations (version) VALUES ('20121008143346');

INSERT INTO schema_migrations (version) VALUES ('20121008143348');

INSERT INTO schema_migrations (version) VALUES ('20121010193516');

INSERT INTO schema_migrations (version) VALUES ('20121012172350');

INSERT INTO schema_migrations (version) VALUES ('20121030131311');

INSERT INTO schema_migrations (version) VALUES ('20121112144229');

INSERT INTO schema_migrations (version) VALUES ('20121112150632');

INSERT INTO schema_migrations (version) VALUES ('20121112201001');

INSERT INTO schema_migrations (version) VALUES ('20121113144441');

INSERT INTO schema_migrations (version) VALUES ('20121121185801');

INSERT INTO schema_migrations (version) VALUES ('20121127191652');

INSERT INTO schema_migrations (version) VALUES ('20121129213135');

INSERT INTO schema_migrations (version) VALUES ('20121129223138');

INSERT INTO schema_migrations (version) VALUES ('20121217160251');

INSERT INTO schema_migrations (version) VALUES ('20130102214248');

INSERT INTO schema_migrations (version) VALUES ('20130104151248');

INSERT INTO schema_migrations (version) VALUES ('20130107213621');

INSERT INTO schema_migrations (version) VALUES ('20130117110946');

INSERT INTO schema_migrations (version) VALUES ('20130124162338');

INSERT INTO schema_migrations (version) VALUES ('20130126194546');

INSERT INTO schema_migrations (version) VALUES ('20130129122435');

INSERT INTO schema_migrations (version) VALUES ('20130129175157');

INSERT INTO schema_migrations (version) VALUES ('20130131094411');

INSERT INTO schema_migrations (version) VALUES ('20130204132701');

INSERT INTO schema_migrations (version) VALUES ('20130204200037');

INSERT INTO schema_migrations (version) VALUES ('20130213195231');

INSERT INTO schema_migrations (version) VALUES ('20130215063241');

INSERT INTO schema_migrations (version) VALUES ('20130226133232');

INSERT INTO schema_migrations (version) VALUES ('20130307213229');

INSERT INTO schema_migrations (version) VALUES ('20130318165325');

INSERT INTO schema_migrations (version) VALUES ('20130318171849');

INSERT INTO schema_migrations (version) VALUES ('20130319162919');

INSERT INTO schema_migrations (version) VALUES ('20130321121430');

INSERT INTO schema_migrations (version) VALUES ('20130403133149');

INSERT INTO schema_migrations (version) VALUES ('20130409161304');

INSERT INTO schema_migrations (version) VALUES ('20130409185838');

INSERT INTO schema_migrations (version) VALUES ('20130418212325');

INSERT INTO schema_migrations (version) VALUES ('20130424120401');

INSERT INTO schema_migrations (version) VALUES ('20130430162020');

INSERT INTO schema_migrations (version) VALUES ('20130514202353');

INSERT INTO schema_migrations (version) VALUES ('20130515153703');

INSERT INTO schema_migrations (version) VALUES ('20130520172232');

INSERT INTO schema_migrations (version) VALUES ('20130521162439');

INSERT INTO schema_migrations (version) VALUES ('20130529211902');

INSERT INTO schema_migrations (version) VALUES ('20130604124100');

INSERT INTO schema_migrations (version) VALUES ('20130612212512');

INSERT INTO schema_migrations (version) VALUES ('20130613090036');