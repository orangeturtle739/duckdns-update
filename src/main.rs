#[macro_use]
extern crate clap;

use serde_derive::Deserialize;
use std::fs;

#[derive(Debug, Deserialize)]
struct Config {
    domain: String,
    token: String,
}

fn duckdns_update(domain: &str, token: &str) -> Result<String, String> {
    let resp = ureq::get(&format!(
        "https://www.duckdns.org/update?domains={domain}&token={token}&verbose=true",
        domain = domain,
        token = token
    ))
    .call();
    let ok = resp.ok();
    let text = resp
        .into_string()
        .or_else(|io_error| Err(io_error.to_string()))?;

    if ok && text.starts_with("OK") {
        Ok(text)
    } else {
        Err(text)
    }
}

fn main() {
    let matches = clap_app!(duckdns_update =>
        (version: "0.1.0")
        (author: "Jacob Glueck <swimgiraffe435@gmail.com>")
        (about: "Updates a duckdns ddns record")
        (@arg CONFIG: +required "Path to the configuration file")
    )
    .get_matches();
    let config: Config =
        toml::from_str(&fs::read_to_string(matches.value_of("CONFIG").unwrap()).unwrap()).unwrap();
    let result = duckdns_update(&config.domain, &config.token);
    println!("{}", result.as_ref().unwrap_or_else(|x| x));
    std::process::exit(match result {
        Ok(_) => 0,
        Err(_) => 1,
    });
}
