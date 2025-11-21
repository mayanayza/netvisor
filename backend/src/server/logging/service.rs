#[derive(Clone)]
pub struct LoggingService {}

impl LoggingService {
    pub fn new() -> Self {
        Self {}
    }
}

impl Default for LoggingService {
    fn default() -> Self {
        Self::new()
    }
}
