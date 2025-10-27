# STSA Deep File-by-File Verification and Remediation (ReAct Style)

Context:
You are working with Swamy's Tech Skills Academy (STSA) Knowledge Base, a comprehensive educational learning system targeting Lead Architect / Director Technology mastery. The repository follows strict educational content standards and multi-domain expertise development across Development, AI/ML, Data Science, and DevOps.

Target Folders for Verification:

- `<<Folder Full Path>>`

Primary Objective:
Perform a COMPREHENSIVE audit of every file using STSA-specific educational standards and quality criteria. Open and inspect file contents, run the checks below, and produce an actionable, structured report with suggestions and fixes. Use a ReAct approach internally — reasoning and actions to determine facts and fix proposals — BUT DO NOT OUTPUT ANY CHAIN-OF-THOUGHT OR PRIVATE REASONING. Only output the final results in the requested formats.

STSA-Specific Verification Checks (Run for Every File)

A. **File Content Inspection**: Ensure you open and verify every file (no file skipped).
B. **STSA Educational Standards**: Validate content against copilot-instructions.md requirements.
C. **Content Accuracy & Completeness**: Verify educational content accuracy, technical correctness, and completeness for its learning objectives.
D. **STSA Metadata Requirements**: Check for proper Learning Level, Prerequisites, Estimated Time (27 minutes), Learning Objectives, and Related Topics sections.
E. **Numbering Convention Compliance**: Ensure zero-padded numeric prefixes starting at `01_` (NEVER `00_`).
F. **Broken Links & References**: Check README files, internal links, and asset references.
G. **Content Quality**: Spellcheck, grammar check, and character encoding validation (no � symbols).
H. **Redundancy & Relevance**: Detect duplicate content and flag irrelevant files for removal.
I. **Repository Structure**: Verify proper folder organization, naming conventions, and navigability.
J. **Content Currency**: Verify content is up-to-date and follows current STSA standards.
K. **Improvement Recommendations**: Provide concrete suggestions with code snippets and exact replacements.
L. **Encoding & Format**: Detect UTF-8 encoding issues, BOMs, and markdown compliance.
M. **File & Naming Conventions**: Ensure kebab-case for filenames, consistent naming across the repository.
N. **Markdown Standards**: Check markdownlint compliance, proper heading hierarchy, code fence languages.
O. **Educational Content Quality**: Verify learning progression, 27-minute segments, multi-part structure.
P. **Zero-Copy Policy Compliance**: Ensure no verbatim copying from sources, original educational content only.
Q. **Cross-Domain Integration**: Check proper domain placement and cross-references between tracks.

STSA Educational Content Standards (Apply Across Repository)

- **Educational Focus**: Content must be original, educational, and tailored to Lead Architect / Director Technology learning progression.
- **27-Minute Learning Segments**: Modular content designed for focused 27-minute sessions with clear learning objectives.
- **Multi-Part Structure**: Complex topics split into Part 1, Part 2, ... Part N for digestible learning.
- **STSA Metadata**: Every significant content piece must include Learning Level, Prerequisites, Estimated Time, Learning Objectives, and Related Topics.
- **Zero-Copy Policy**: No verbatim copying from sources; all content must be transformative and original.
- **Numbering Convention**: Use zero-padded numeric prefixes starting at `01_` (NEVER `00_`).
- **Character Encoding**: UTF-8 only, no replacement characters (�), proper Unicode handling.
- **Markdown Compliance**: Follow markdownlint rules, proper heading hierarchy, language-specified code fences.
- **ASCII-First Diagrams**: Provide ASCII diagrams in text code fences, Mermaid as enhancement with ASCII fallback.
- **Cross-Domain Integration**: Proper placement in domain folders (Development, AI-ML, Data Science, DevOps) with cross-references.
- **File Naming**: kebab-case for filenames, consistent naming across repository.
- **Content Length**: Maximum 175 lines per module to maintain focus and readability.
- **Educational Quality**: Clear progression from Beginner → Practitioner → Professional → Leader → Architect levels.

STSA Verification Tools & Execution Methods

- **File Content Analysis**: Open each markdown file and parse educational content structure.
- **STSA Compliance Verification**: Run checks against copilot-instructions.md requirements using PowerShell automation scripts.
- **Markdownlint Validation**: Execute `npx markdownlint-cli2 "**/*.md"` for markdown compliance.
- **Link Validation**: Use lychee link checker `docker run --rm -v "${PWD}:/workspace" -w /workspace lycheeverse/lychee --config lychee.toml .`
- **Educational Structure Analysis**: Verify 27-minute learning segments, multi-part organization, and learning objectives.
- **Metadata Verification**: Check for required STSA metadata blocks (Learning Level, Prerequisites, Estimated Time, etc.).
- **Cross-Reference Validation**: Ensure proper domain placement and cross-track integration.
- **Character Encoding Validation**: Detect UTF-8 issues and replacement characters (�).
- **Numbering Convention Check**: Verify zero-padded `01_` prefixes (no `00_` prefixes allowed).
- **Content Quality Assessment**: Educational accuracy, original content verification, zero-copy policy compliance.
- **Repository Structure Validation**: Verify proper folder organization per STSA standards.

Output requirements (MUST follow exactly)

1. **SUMMARY (Top-level)**

   - repo_name: string
   - total_files_checked: int
   - total_issues_found: int
   - stsa_compliance_percentage: float
   - high_severity_count / medium / low
   - suggested_next_steps (3 bullets)

1. **DETAILED_REPORT (array of file reports)**

   For each file produce an object with:

   - file_path: string
   - checks_passed: [list of check keys passed e.g., A,B,F,...]
   - stsa_metadata_present: boolean
   - educational_quality_score: int (0-100)
   - issues: [
       {
         id: string (unique, e.g., "STSA-001-metadata"),
         severity: "high"|"medium"|"low",
         line_start: int|null,
         line_end: int|null,
         description: string,
         suggested_fix: string (a patch or exact replacement snippet),
         fix_type: "replace"|"delete"|"add"|"rename"|"format"|"link-fix"|"metadata-add",
         stsa_violation_type: string
       }
     ]
   - overall_status: "stsa_compliant"|"needs_stsa_updates"|"remove"
   - quick_fix_patch: (if small) a unified diff/patch applying the fix, or null

1. **STSA_COMPLIANCE_ISSUES (array)**

   - issue_id
   - description (e.g., missing Learning Objectives, incorrect numbering convention)
   - affected_files: []
   - stsa_standard_violated: string
   - suggested_fix: patch or instructions

1. **EDUCATIONAL_CONTENT_ANALYSIS**

   - learning_progression_score: 0-100
   - multi_domain_integration_score: 0-100
   - zero_copy_compliance: boolean
   - content_originality_score: 0-100

1. **RENAMING_SUGGESTIONS (array)**

   - current_path
   - suggested_path
   - reason
   - stsa_convention_alignment: boolean

1. **FILES_TO_REMOVE (array)**

   - path
   - reason
   - impact_summary
   - stsa_relevance_score: 0-100

1. **STSA_METADATA_SUMMARY**

   - files_with_complete_metadata: int
   - files_missing_learning_objectives: int
   - files_missing_prerequisites: int
   - files_missing_estimated_time: int
   - files_with_incorrect_numbering: int
   - educational_quality_distribution: object

1. **CROSS_DOMAIN_INTEGRATION_SUMMARY**

   - development_track_files: int
   - ai_ml_track_files: int
   - data_science_track_files: int
   - devops_track_files: int
   - cross_references_present: int
      - domain_placement_issues: []

Formatting rules for output:

- Output only JSON (no prose outside JSON) so it can be parsed by automation.
- JSON must be UTF-8, compact but human-readable (use 2-space indentation).
- If you include patches, ensure diffs use unified diff format and are properly escaped inside JSON strings.

Strict privacy & reasoning constraint:

- Use ReAct-style internal reasoning and actions to determine findings BUT DO NOT OUTPUT ANY CHAIN-OF-THOUGHT, internal logs, or private reasoning. Only provide the JSON structured output described above.
- If you cannot confirm something (e.g., external API version), mark it "needs_verification" and state what command or URL the operator should run to confirm.

Deliverables:

- The complete JSON report as described above.
- For each suggested_fix that is small (<= 30 lines), include a quick_fix_patch.
- For larger fixes, include exact instructions and code snippets for maintainers to apply the change.
- A final top-level "suggested_next_steps" with three clear actions (e.g., run linter, open PR with patches, run link-checker CI).

Formatting rules for output:

- Output only JSON (no prose outside JSON) so it can be parsed by automation.
- JSON must be UTF-8, compact but human-readable (use 2-space indentation).
- If you include patches, ensure diffs use unified diff format and are properly escaped inside JSON strings.

Strict privacy & reasoning constraint:

- Use ReAct-style internal reasoning and actions to determine findings BUT DO NOT OUTPUT ANY CHAIN-OF-THOUGHT, internal logs, or private reasoning. Only provide the JSON structured output described above.
- If you cannot confirm something (e.g., external API version), mark it “needs_verification” and state what command or URL the operator should run to confirm.

Deliverables:

- The complete JSON report as described above.
- For each suggested_fix that is small (<= 30 lines), include a quick_fix_patch.
- For larger fixes, include exact instructions and code snippets for maintainers to apply the change.
- A final top-level "suggested_next_steps" with three clear actions (e.g., run linter, open PR with patches, run link-checker CI).

Behavioral expectations:

- **STSA-First Approach**: Prioritize educational quality and STSA compliance over generic software standards.
- **Educational Value Focus**: Flag content that doesn't meet educational excellence standards for Lead Architect learning progression.
- **Zero-Copy Enforcement**: Strictly verify no verbatim copying from sources; all content must be transformative and original.
- **27-Minute Learning Optimization**: Ensure content segments are optimized for focused 27-minute learning sessions.
- **Multi-Domain Integration**: Verify proper cross-track references and domain placement (Development, AI-ML, Data Science, DevOps).
- **STSA Metadata Compliance**: Prioritize missing Learning Objectives, Prerequisites, and Estimated Time as high-severity issues.
- **Conservative Quality Approach**: Prefer flagging potential educational quality issues rather than ignoring them.
- **Backward Compatibility**: When suggesting fixes, maintain educational progression and cross-reference integrity.

STSA-Specific Deliverables:

- Complete JSON report following STSA output requirements above.
- STSA compliance scoring and educational quality assessment for each file.
- Cross-domain integration analysis and placement recommendations.
- Three clear next steps focused on achieving 100% STSA compliance.
- Educational content transformation recommendations where needed.

Start now: open every file in the repository tree above, run the STSA-specific checks, and produce the JSON report. Remember: use ReAct internally but output only the structured JSON with STSA educational focus.
