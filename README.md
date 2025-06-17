# ssrf_advanced.pl – Advanced SSRF PoC for SonicWall SMA1000

**Author:** TURKI ALNAFIE  
**Created:** 2025-06-18  

---

## Table of Contents

- [Overview](#overview)  
- [Features](#features)  
- [Prerequisites](#prerequisites)  
- [Installation](#installation)  
- [Configuration](#configuration)  
- [Usage](#usage)  
- [Options](#options)  
- [Payloads File Format](#payloads-file-format)  
- [Logging & Output](#logging--output)  
- [Security & Compliance](#security--compliance)  
- [Best Practices](#best-practices)  
- [Contributing](#contributing)  
- [License](#license)  
- [Author](#author)  

---

## Overview

`ssrf_advanced.pl` is a multithreaded Perl proof-of-concept script designed to enumerate and trigger the CVE-2025-40595 SSRF vulnerability in SonicWall SMA1000’s Workplace interface. It reads a list of attacker-controlled payload URLs, URI-encodes them correctly, and issues concurrent HTTP requests to validate SSRF reachability and impact.

---

## Features

- **Concurrency** via Perl threads to test many payloads in parallel  
- **Strict URI encoding** (no double-escape pitfalls)  
- **Flexible schemes**: `http://`, `gopher://`, `file://`, etc.  
- **Verbose mode** for real-time request/response summaries  
- **Error logging** of non-200 responses with timestamps  
- **CLI-driven**: easy integration into security workflows and automation pipelines  

---

## Prerequisites

- Perl **≥ 5.10**  
- CPAN modules (install via `cpan install` or your OS package manager):  
  - `LWP::UserAgent`  
  - `URI::Escape`  
  - `Getopt::Long`  
  - `Thread::Queue`  
  - `threads`  
