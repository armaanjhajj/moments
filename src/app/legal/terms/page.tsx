export default function TermsPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16">
      <h1 className="text-3xl font-semibold">Terms of Service</h1>
      <p className="text-muted-foreground mt-4">
        Last updated: {new Date().toLocaleDateString()}
      </p>
      <p className="mt-4">
        These are placeholder terms. Detailed terms will be available prior to
        public launch.
      </p>
    </div>
  );
}
