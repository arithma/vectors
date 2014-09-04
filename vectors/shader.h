//
//  shader.h
//  vectors
//
//  Created by arithma on 5/18/14.
//
//

#ifndef __vectors__shader__
#define __vectors__shader__

#include <iostream>

GLuint compileShader ( GLenum type, const char *shaderSrc );
GLuint compileShaderFromFile ( GLenum type, const char *filename);

#endif /* defined(__vectors__shader__) */
