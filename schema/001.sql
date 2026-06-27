-- =============================================================================
-- ORGANIZATIONAL
-- =============================================================================
CREATE TABLE teams (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_name varchar NOT NULL UNIQUE,
    description text NULL,
    email varchar NULL,
    metadata jsonb NULL
);

CREATE TABLE contacts (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name varchar NOT NULL,
    email varchar NOT NULL UNIQUE,
    metadata jsonb NULL
);

-- team members (many-to-many, a contact can be in multiple teams)
CREATE TABLE team_contacts (
    team_id int NOT NULL REFERENCES teams(id),
    contact_id int NOT NULL REFERENCES contacts(id),
    role varchar NULL,
    PRIMARY KEY (team_id, contact_id)
);

CREATE TABLE services (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id int NOT NULL REFERENCES teams(id),
    service_name varchar NOT NULL UNIQUE,
    description text NULL,
);

CREATE TABLE cost_centers (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cost_center_code varchar NOT NULL UNIQUE,
    cost_center_name varchar NOT NULL,
    description text NULL
);

CREATE TABLE projects (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id int NOT NULL REFERENCES teams(id),
    cost_center_id int NULL REFERENCES cost_centers(id),
    project_name varchar NOT NULL UNIQUE,
    description text NULL,
    start_date date NULL,
    end_date date NULL,
);

CREATE TABLE operating_systems (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fullname varchar not null unique,
    name varchar,
    version varchar,
    major_version varchar,
    minor_version varchar,
    vendor varchar,
    obsolete boolean
);

-- =============================================================================
-- VM TABLES
-- =============================================================================
CREATE TABLE vms (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hypervisor_host_id int REFERENCES hypervisor_hosts(id),
    compute_pool_id int REFERENCES compute_pools(id),
    power_state varchar,
    team_id int REFERENCES teams(id),
    project_id int references projects(id),
    environment_id int REFERENCES environments(id),
    service_id int references services(id),
    arch_id varchar,
    os_id int REFERENCES operating_systems(id),
    vm_status varchar,
    vm_name varchar NOT NULL UNIQUE,
    ipv4 varchar NOT NULL UNIQUE,
    shortname varchar unique,
    fqdn varchar unique,
    refname varchar unique,
    vm_uuid varchar NULL UNIQUE,
    cpus int NULL,
    memory_mb int8 NULL,
    storage_total_gb int8 NULL,
    has_backup boolean,
    has_dr boolean,
    kernel varchar,
);

CREATE TABLE vm_disks (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vm_id int NOT NULL REFERENCES vms(id),
    datastore_id int REFERENCES datastores(id),
    disk_format_id int NULL REFERENCES disk_formats(id),
    label varchar NULL,
    size_gb int8 NOT NULL,
    disk_path varchar NULL,
    boot_disk bool NOT NULL DEFAULT false
);

CREATE TABLE vm_mounts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vm_id int not null references vms(id),
    mountpoint varchar not null,
    source varchar not null,
    fstype  varchar not null,
    opts varchar[],
    status varchar,
    in_fstab boolean,
    size bigint,
    used_last_seen bigint,
    used_pct numeric,
    CONSTRAINT uq_vm_mounts UNIQUE (vm_id, source, mountpoint)
);

CREATE TABLE vm_nics (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vm_id int NOT NULL REFERENCES vms(id),
    network_id int REFERENCES networks(id),
    adapter_type_id int NULL REFERENCES adapter_types(id),
    mac_address varchar NULL,
    ipv4 varchar NULL,
    ipv6 varchar NULL,
    connected bool NOT NULL DEFAULT true
);
