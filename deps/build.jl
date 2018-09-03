using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["liblbfgsb"], :liblbfgsb),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/Gnimuc/L-BFGS-B-Builder/releases/download/v3.0.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/LBFGSB.v3.0.0.aarch64-linux-gnu.tar.gz", "f5b4ef8b91f7d60a72e02fe568fdcf57fba9def9c5dbbab68fb656a8730719d8"),
    Linux(:aarch64, :musl) => ("$bin_prefix/LBFGSB.v3.0.0.aarch64-linux-musl.tar.gz", "694b4f35728386c609bf3361d3eed1c9d440d82f143b914ba405f57031a9ab79"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/LBFGSB.v3.0.0.arm-linux-gnueabihf.tar.gz", "95dd066d7cc6e05c215c3f6b6184375f913177d18fc2e4e84e265deb8eb6b642"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/LBFGSB.v3.0.0.arm-linux-musleabihf.tar.gz", "820fd644c0258580fde3763ad5ea727b21f1ec387d00a9507035031166516545"),
    Linux(:i686, :glibc) => ("$bin_prefix/LBFGSB.v3.0.0.i686-linux-gnu.tar.gz", "be754a0954c2a45e6c9db664d6e355b50b74a2a4ce8d97c4e74933b6697b3db6"),
    Linux(:i686, :musl) => ("$bin_prefix/LBFGSB.v3.0.0.i686-linux-musl.tar.gz", "2dfb726870e342fa14f6b270d2fb0b48bcf0069c4554148eb65fde9a5ff8511d"),
    Windows(:i686) => ("$bin_prefix/LBFGSB.v3.0.0.i686-w64-mingw32.tar.gz", "7876bdf00bdf373fa4b2ec149def708fe89f2f76192a376a33831af44a493337"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/LBFGSB.v3.0.0.powerpc64le-linux-gnu.tar.gz", "df2b09d69231b2f0a8b3f247114a8263f4d1ada303e10c29eeb7a9327ec69456"),
    MacOS(:x86_64) => ("$bin_prefix/LBFGSB.v3.0.0.x86_64-apple-darwin14.tar.gz", "39ae7184a922a2f4cfb14ba39a131b52800eb6a3ce266dca1e5c29745b8fa849"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/LBFGSB.v3.0.0.x86_64-linux-gnu.tar.gz", "fa3e9a1c169ac361233884305f06079353460c5910a96699ef6afc5d2d11deb0"),
    Linux(:x86_64, :musl) => ("$bin_prefix/LBFGSB.v3.0.0.x86_64-linux-musl.tar.gz", "de4e7cd7ef7cf530ad84ee17ef142d52d82b0c10bc4255b307ac6e116e73d6e6"),
    FreeBSD(:x86_64) => ("$bin_prefix/LBFGSB.v3.0.0.x86_64-unknown-freebsd11.1.tar.gz", "e3198c82e18459beffdb5fa21b7909410e50554b7606b3e55ad30896fae8b61f"),
    Windows(:x86_64) => ("$bin_prefix/LBFGSB.v3.0.0.x86_64-w64-mingw32.tar.gz", "9b352e959cefc9d13e9cb281182a28bc005b30281cb311651195266533da1e1e"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
