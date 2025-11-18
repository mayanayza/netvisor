#[cfg(test)]
mod dependency_tests {
    #[test]
    fn ensure_no_openssl_dependencies() {
        // This test ensures we don't accidentally pull in OpenSSL
        // Run: cargo tree -i openssl-sys --target all

        let output = std::process::Command::new("cargo")
            .args(["tree", "-i", "openssl-sys", "--target", "all"])
            .current_dir(env!("CARGO_MANIFEST_DIR"))
            .output()
            .expect("Failed to run cargo tree");

        let stdout = String::from_utf8_lossy(&output.stdout);

        // If openssl-sys is not in the dependency tree, cargo tree returns empty with a warning
        // If it IS in the tree, it will show the dependency chain
        assert!(
            stdout.contains("warning: nothing to print") || stdout.is_empty(),
            "Found OpenSSL dependencies! This breaks musl cross-compilation.\n\
             Run 'cargo tree -i openssl-sys --target all' to see the dependency chain.\n\
             Make sure all dependencies use 'default-features = false' with 'rustls-tls' features.\n\
             Output:\n{}",
            stdout
        );
    }
}
