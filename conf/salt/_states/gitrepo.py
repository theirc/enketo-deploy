import os.path

def _clone_repo(repo, user, dir):
    ret_val = __salt__['git.clone'](
        cwd=dir,
        repository=repo,
        user=user
    )

def _fetch_repo(user, dir):
    ret_val = __salt__['cmd.run'](
        "git fetch",
        user=user,
        cwd=dir,
    )

def _reset_repo(user, dir, rev):
    ret_val = __salt__['cmd.run'](
        "git reset --hard '%(rev)s'" % {'rev': rev},
        user=user,
        cwd=dir,
    )

def pin(name, repo, user, dir, rev, submodules=False):
    """
    Clone or update a checkout of a git repo, and forcibly
    reset it to a specified revision.

    :param repo: URL of the git repo
    :param user: User to run as
    :param dir: Directory path of the cloned repo.  (Parent directories are NOT created first.)
    :param rev: Tag/Branch name/Commit that the checkout should be reset to.
    :param submodules: If True, do a recursive init on submodules after updating.
    :return:
    """
    if not os.path.exists(dir) or not os.path.exists(dir + "/.git"):
        _clone_repo(repo, user, dir)
    else:
        _fetch_repo(user, dir)
    _reset_repo(user, dir, rev)
    if submodules:
        __salt__['cmd.run'](
            "git submodule update --init --recursive",
            user=user,
            cwd=dir,
        )

    return {
        'name': name,
        'changes': {'changes': 'returning changes not implemented'},
        'result': True,
        'comment': 'returning comments not implemented'
    }
