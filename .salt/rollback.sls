


irssi-rollback-faileproject-dir:
  cmd.run:
    - name: |
            if [ -d "/srv/projects/irssi/archives/2014-10-12_22_01-43_8c845354-a54d-4367-893a-2a834c43808b/project" ];then
              rsync -Aa --delete "/srv/projects/irssi/project/" "/srv/projects/irssi/archives/2014-10-12_22_01-43_8c845354-a54d-4367-893a-2a834c43808b/project.failed/"
            fi;
    - user: irssi-user

irssi-rollback-project-dir:
  cmd.run:
    - name: |
            if [ -d "/srv/projects/irssi/archives/2014-10-12_22_01-43_8c845354-a54d-4367-893a-2a834c43808b/project" ];then
              rsync -Aa --delete "/srv/projects/irssi/archives/2014-10-12_22_01-43_8c845354-a54d-4367-893a-2a834c43808b/project/" "/srv/projects/irssi/project/"
            fi;
    - user: irssi-user
    - require:
      - cmd:  irssi-rollback-faileproject-dir
