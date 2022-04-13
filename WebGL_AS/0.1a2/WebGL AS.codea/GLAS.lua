-- OpenGL bindings
local GL = ASSource('gl', asset.documents.WebGL_AS.libs.gl)

-- GLAS Util
--
-- Provides AssemblyScript helper types such as
-- Vectors
-- Matrices
-- Quaternions
local GLAS_UTIL = ASSource('glas_util', asset.documents.WebGL_AS.libs.glas_util)

-- GLAS
GLAS = ASSource('glas', asset.documents.WebGL_AS.libs.glas, nil, {
    GL,
    GLAS_UTIL
})
