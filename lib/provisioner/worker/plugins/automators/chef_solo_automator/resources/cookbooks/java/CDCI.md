Continuously deploying cookbooks to chef supermarket with Travis CI


As a cookbook maintainer it is hard to find the time to verify, tests and release new versions of a cookbook, especially when it is fairly stable and used by many.

I happened to find through some searching and piecing together of snipits a way to publish using the build system we are already using, TravisCI.

# Create a new user for deploying to Supermarket

You likely do not want your workstation user to share the same permissions with hosted chef incase of any compromise of Travis CI, so it's probably a good idea to create a separate account to do deploy.

# Install the Travis cli gem:

```bash
gem install travis
```

# Generate a new Github token for travis cli - <https://github.com/settings/tokens>

```bash
travis login --github-token=<tokenhere>
```


```bash
cd cookbooks/mycookbook/
mkdir -p .travis/
# add this directory to chefignore & .gitignore
echo '.travis/*' >> chefignore
echo '.travis/' >> .gitignore
```

Encrypt the key
http://docs.travis-ci.com/user/encrypting-files/
```bash
cp ~/.chef/key.pem .travis/key.pem
travis encrypt-file .travis/key.pem --add # Will add the required commands to travis.yml

# Don't keep the plaintext key around!
rm .travis/key.pem
```

Finally, add a `deploy` section to to your travis.yml. [Documentation on Travis-CI's dpl and chef-supermarket.](https://github.com/travis-ci/dpl#chef-supermarket)

```yml
deploy:
  edge: true
  provider: chef-supermarket
  user_id: agileorbit
  client_key: ".travis/key.pem"
  cookbook_category: Other
  skip_cleanup: true
  on:
    tags: true
```

This will publish when a new tag is pushed to Github. Other changes won't run the deploy section.

# Conclusion

This will allow us to ship changes quickly with
# Notes

Creating a git tag:
```bash
git commit -am 'Changes for release v1.2.3'
git tag v1.2.3
git push origin v1.2.3
```
More on [git tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
