export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16">
      <h1 className="text-3xl font-semibold">Privacy Policy</h1>
      <p className="text-muted-foreground mt-4">
        Last updated: {new Date().toLocaleDateString()}
      </p>
      <p className="mt-4">
        This is a placeholder privacy policy. We respect your privacy. More
        details will be provided before public launch.
      </p>
    </div>
  );
}
