# Quick Reference for Non-Containerized Environments
This document shows additional command quick-referece for legacy non-containerized environments.

See [Quick Reference](./quick_reference.md) for the full command quick reference and a directory of detailed guides.


**Database and services:**
```bash
sudo pulpcore-manager ...                               # Run pulpcore-manager commands
```

**Testing**:
```bash
# For individual test files, ALWAYS use ktest:
cd $GITDIR/katello
ktest /path/to/test_file.rb                             # Specific file
ktest /path/to/test_file.rb -n test_method_name         # Specific method
```