# We are doing a multi-stage build to first extract the dependencies of the
# system role. In a subsequent stage we can install the dependencies.

FROM quay.io/centos-bootc/centos-bootc:stream10 as ansible-stage
RUN dnf -y install ansible-core
RUN ansible-galaxy collection install fedora.linux_system_roles
RUN mkdir -p /deps

# TODO: Discovering the path must be easier.
RUN /root/.ansible/collections/ansible_collections/fedora/linux_system_roles/roles/podman/.ostree/get_ostree_data.sh packages runtime centos-10 raw > /deps/ansible.txt || true

# In the final/subsequent stage, we can access the dependencies without leaking
# them into the image.
FROM quay.io/centos-bootc/centos-bootc:stream10
RUN --mount=type=bind,from=ansible-stage,source=/deps/,target=/deps cat /deps/ansible.txt
