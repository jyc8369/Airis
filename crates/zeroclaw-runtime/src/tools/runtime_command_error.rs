pub(super) fn format_runtime_command_error(error: &anyhow::Error) -> String {
    let message = format!("{error:#}");
    crate::i18n::get_required_cli_string_with_args(
        "tool-runtime-command-build-failed",
        &[("error", message.as_str())],
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generic_runtime_error_preserves_the_full_chain() {
        let error = anyhow::Error::msg("inner runtime cause").context("outer runtime context");

        let message = format_runtime_command_error(&error);

        assert!(message.contains("outer runtime context"));
        assert!(message.contains("inner runtime cause"));
    }
}
