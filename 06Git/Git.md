# Version Control (Git)

## Git's Data Model

### Snapshots

- Git models the history of a collection of files and folders as a series of snapshots.
- Terminology
  - File: "blob", a bunch of bytes
  - Directory: "tree", maps names to blobs or trees
  - Snapshot: the top-level tree that is being tracked, also called "**commit**"

### Modeling history: relating snapshots

- In Git, a history is modeled as a directed acyclic graph (**DAG**) of snapshots

  - Each snapshot in Git refers to **a set of** "parents", the snapshots that preceded it.
  - A snapshot might descend from multiple parents. E.g., combining (merging) two parallel branches of development.
  - A commit is modeled as a node in this graph, and the node has edges that point to all of its parents.
  - A commit includes some metadata (author, editing information)
  - An example where two branches are merged, combining some features that are developed in parallel:

  ```asciiarmor
  o <-- o <-- o <-- o <---- o (the merged commit)
              ^            /
               \          v
                --- o <-- o
  ```

### Data Model as Pseudocode

```pseudocode
// a file is a bunch of bytes
type blob = array<byte>

// a directory contains named files or directories
type tree = map<string, tree | blob>

// a commit has parents, metadata and the top-level tree
type commit = struct {
		parents: array<commit>
		author: string
		message: string
		snapshot: tree
}
```

### Objects and content-addressing

- An "object" is a blob, tree or commit

  ```pseudocode
  type object = blob | tree | commit
  ```

- Objects are stored as a hash table using [SHA-1 hash](https://en.wikipedia.org/wiki/SHA-1)
  - When a object reference other objects, they don't actually contain them in their on-disk representation, but have a reference to them by their hash
  - Objects are all **immutable**, because modifying the history does not make any sense
  - For example, the tree for the example directory structure, we can visualize the content corresponding to a certain hash using `git cat-file -p <hash>`:

```pseudocode
An Example Directory Structure 
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hello world")
|
+- baz.txt (blob, contents = "git is wonderful")


$ git cat-file -p 698281bc680d1995c5f4caaf3359721a5a58d48d
100644 blob 4448adbf7ecd394f42ae135bbeed9676e894af85    baz.txt
040000 tree c68d233a33c5c06e0340e4c224f0afca87c8ce87    foo

$ git cat-file -p 4448adbf7ecd394f42ae135bbeed9676e894af85
git is wonderful
```

```pseudocode
objects = map<string, object>

def store(object o):
		id = sha1(o)
		objects[id] = 0

def load(id):
		return objects[id]	
```

### References

- References are human-readable names for SHA-1 hashes. They are pointers to commits.

- References are mutable, which means it can be updated. E.g., `master` reference usually points to the latest commit in the main branch of development.

- With the following data structure, Git can use human-readable names like "master" to refer to a particular snapshot in the history instead of a long hexadecimal string

  ```pseudocode
  references = map<string, string>
  
  def update_reference(name, id):
  		references[name] = id
  		
  def read_reference(name):
  		return references[name]
  		
  def load_reference(name_or_id):
  		if name_or_id in references:
  				return load(references[name_or_id])
      else:
      		return load(name_or_id)
  ```

- In the history, we have a notion of "where we currently are", which is called **HEAD**. In this way, when we take a new snapshot, we will know what it is relative to. (how we set the `parents` field in `struct commit`)

### Repositories

- What is a git repository? On disk, all Git stores are:
  - `objects`
  - `references`
- All `git` commands map to some manipulation of the commit DAG by adding objects and adding/updating objects.
  - e.g. discard uncommited changes and make the 'master' ref point to commit `5d83f9e`
    - `git checkout master`
    - `git reset --hard 5d83f9e` 

## Staging Area

- Considering two possible scenarioes:
  - Create two seperate commits for the two separate features you've implemented.
  - You have debugging print statements added all over your code along with a bugfix. And you want to commit the bugfix while discarding all the print statements.
- "Staing area" allows you to specify which modifications should be included in the next snapshot.

## Git Command: Manipulations of Objects or References

### Git Basics

- `git help <command>`: get help for some git `<command>`
- `git init`: creates a new git repo, with the objects and the references stored in the `.git`
- `git status`: tells you what's going on
- `git add <filename>`: add files to staging area
- `git commit`: creates a new commit
- `git log`: shows a flatten log of history, but sometimes confusing
- `git log --all --graph --decorate`: visualizes history as a DAG
- `git checkout <revision>`: updates **HEAD** reference and current branch, potentially discarding your current changes that have not been commited
- `git diff <filename>`: show changes you made relative to the staging area
- `git diff <revision> <filename>`: shows differences in a file between the specified snapshot and the current staging area

### Write Good Commit Messages

- If the change is very simple and self-evident, just use `commit -m ` with an one-line explanation.
- If the change is relatively significant, use a text editor to write the message following these rules:
  - Separate subject from body with a blank line
  - Limit the subject line to about 50 characters (Be concise!)
  - Capitalize the subject line
  - Do not end the subject line with a period
  - Use the imperative mood in the subject line
    - Merge branch 'my feature'
    - Revert "add the thing with the stuff"
    - Merge pull request #123 from username
  - Wrap the body at 72 characters
    - Can be achieved by configure Vim
  - Use the body to explain what and why, instead of how (code explains it!)

### Branching and Merging for Parallel Development

- `git branch`: shows branches
- `git branch <name>`: creates a branch
- `git checkout -b <name>`: creates a branch and switches to it. This is equivalent to `git branch <name>; git checkout <name>`
- `git merge <revision>`: merges into the current branch. Git will do its best job to merge, but will leave for the programmers when there are conflicts. After fixing the conflict, add the file again and use `git merge --continue` to merge.
- `git mergetool`: use a fancy tool to help resolve merge conflicts
- `git rebase` : rebase set of patches onto a new base

### Remotes

- `git remote`: list remotes
- `git remote add <name> <url>`: add a remote
- `git push <remote> <local branch>:<remote branch>`: send objects to remote and update remote references
- `git branch --set-upstream-to=<remote>/<remote branch>`: set up correspondence between local and remote branch (`--set-upstream-to=origin/master`)
- `git fetch`: retrieve objects/references from a remote
- `git pull`: the same as `git fetch; git merge`
- `git clone <url> <folder name>` : download repository from remote

### Undo

- `git commit --amend`: edit a commit's contents/messages
- `git reset HEAD <file>`: unstage a file
- `git checkout -- <file>`: discard changes

### Advanced Git

- `git config`: highly customizable Git
- `git clone --depth==1`: shallow clone, without the entire version history
- `git add -p`: interactive staging
- `git rebase -i`: interative rebasing
- `git blame`: show who last edited which line
- `git stash`: temporarily remove modifications so that the working directory is as your last commit
  - `git stash pop` will undo the stash and have your modifications again
- `git bisect`: binary search history (e.g. for regressions)
- `.gitignore`: specify intentionally untracked files to ignore (like model/dataset)
  - `.DS_Store`
  - `*.lock`
  - `*.o`

## More about Git

- [Git Pro](https://git-scm.com/book/en/v2) Chapters 1-5 will make you proficient
- [Oh shit Git](https://ohshitgit.com/) Common Git mistakes

