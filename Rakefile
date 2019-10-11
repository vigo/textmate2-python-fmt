AVAILABLE_REVISIONS = ["major", "minor", "patch"]

desc "Bump version"
task :bump, [:revision] do |t, args|
  args.with_defaults(revision: "patch")
  abort "Please provide valid revision: #{AVAILABLE_REVISIONS.join(',')}" unless AVAILABLE_REVISIONS.include?(args.revision)
  system "bumpversion #{args.revision}"
end