# GitHub Branchig

## How to

### 1. Clone or Create the Repository

- **Clone an Existing Repository:**
  ```sh
  git clone <repo-url>
  cd <repo-folder>
  ```
- **Or Create a New Repository on GitHub:**
  - Log in to GitHub and click the **New Repository** button.
  - Set the repository name, description, and choose **main** as the default branch.
  - Clone the new repository locally:
    ```sh
    git clone <repo-url>
    cd <repo-folder>
    ```

---

### 2. Set Up the Main Branch

- Ensure your local **main** branch is up to date:
  ```sh
  git checkout main
  git pull origin main
  ```

---

### 3. Create and Set Up **swamy/feature1**

- **Create the Feature Branch from main:**

  ```sh
  git checkout -b swamy/feature1 main
  git push -u origin swamy/feature1
  ```

- **Work on Feature1:**

  - Make changes to your code.
  - Stage and commit your changes:
    ```sh
    git add .
    git commit -m "Implement feature1 changes"
    git push origin swamy/feature1
    ```

- **Keep Feature1 Aligned with Main (Rebase):**  
  When new commits are added to **main** (e.g., through merging PRs), update your feature branch by rebasing:
  ```sh
  git checkout swamy/feature1
  git fetch origin
  git rebase origin/main
  git push --force-with-lease
  ```
  This repositions **swamy/feature1** on top of the latest **main** commit, ensuring it always shows “0 behind main.”

---

### 4. Create and Set Up **swamy/feature2**

- **Create the Feature Branch from main:**

  ```sh
  git checkout main
  git pull origin main
  git checkout -b swamy/feature2 main
  git push -u origin swamy/feature2
  ```

- **Work on Feature2:**

  - Make changes specific to feature2.
  - Stage and commit your changes:
    ```sh
    git add .
    git commit -m "Implement feature2 changes"
    git push origin swamy/feature2
    ```

- **Keep Feature2 Aligned with Main (Rebase):**  
  As with feature1, when **main** is updated, rebase **swamy/feature2**:
  ```sh
  git checkout swamy/feature2
  git fetch origin
  git rebase origin/main
  git push --force-with-lease
  ```
  This ensures that **swamy/feature2** also always shows “0 behind main.”

---

### 5. Merging Feature Branches into Main

- When a feature is complete and tested, open a Pull Request (PR) on GitHub from **swamy/feature1** (or **swamy/feature2**) to **main**.
- **Merge the PR:**  
  Once reviewed, merge the PR. This updates **main** with the feature branch's commits.
- **After the Merge:**  
  If you keep the feature branch active, perform another rebase on the feature branch if you need to continue work:
  ```sh
  git checkout swamy/feature1
  git fetch origin
  git rebase origin/main
  git push --force-with-lease
  ```
  This ensures it stays “0 behind main.”

---

### Summary

- **Feature Branch Creation:** Both **swamy/feature1** and **swamy/feature2** start from **main**, so initially they show “0 behind main.”
- **Development:** Add commits as you work on your features.
- **Keeping Up-to-Date:** Use `git rebase origin/main` on each feature branch whenever **main** is updated. This forces your branch to replay its commits on top of the latest **main**, ensuring it stays “0 behind main.”
- **Merge:** When merging into **main**, open a PR and merge. If you continue to use the feature branch, rebase again to maintain the “0 behind” state.

Following these steps will keep your feature branches in sync with **main** while letting you track unique commits for each feature.
