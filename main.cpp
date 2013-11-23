#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <GLFW/glfw3.h>
#include <FTGL/ftgl.h>
#include <GLM/glm.hpp>
#include <GLM/gtc/matrix_transform.hpp>
#include <GLM/gtc/matrix_inverse.hpp>
#include <GLM/gtc/type_ptr.hpp>

#include <iostream>
#include <fstream>


using namespace std;

#ifndef M_PI
#define M_PI 3.141592654
#endif

using namespace glm;

static mat4x4 player(mat4x3::null);

GLuint compileShader ( GLenum type, const char *shaderSrc ){
    GLuint shader;
    GLint compiled;
    
    // Create the shader object
    shader = glCreateShader ( type );
    
    assert(shader != 0);
    
    // Load the shader source
    glShaderSource ( shader, 1, &shaderSrc, NULL );
    
    // Compile the shader
    glCompileShader ( shader );
    
    // Check the compile status
    glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );
    
    if ( !compiled )
    {
        GLint infoLen = 0;
        
        glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
        
        if ( infoLen > 1 )
        {
            char* infoLog = new char[infoLen];
            
            glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
            cout <<"Error compiling shader:\n" << infoLog << endl;
            
            delete [] infoLog;
        }
    }
    assert(compiled);
    
    return shader;
}

GLuint compileShaderFromFile( GLenum type, const char *filename){
    char * source;
    {
        // Use file io to load the code of the shader.
        std::ifstream fp( filename , std::ios_base::binary );
        assert(!fp.fail());
        
        fp.seekg( 0, std::ios_base::end );
        long const len = fp.tellg();
        fp.seekg( 0, std::ios_base::beg );
        
        source = new char[len+1];
        fp.read(source, sizeof(char)*len);
        source[len] = NULL;
    }
    return compileShader(type, source);
}

/* OpenGL draw function & timing */
static void draw(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    mat4 player_inv = inverse(player);
}


/* update animation parameters */
static void animate(void)
{
}


/* change view angle, exit upon ESC */
void key( GLFWwindow* window, int k, int s, int action, int mods )
{
    if( action != GLFW_PRESS ) return;
    
    switch (k) {
        case GLFW_KEY_ESCAPE:
            glfwSetWindowShouldClose(window, GL_TRUE);
            break;

        case GLFW_KEY_Z:
            break;
            
        default:
            return;
    }
}


/* new window size */
void reshape( GLFWwindow* window, int width, int height )
{
    GLfloat h = (GLfloat) height / (GLfloat) width;
    GLfloat xmax, znear, zfar;
    
    znear = 5.0f;
    zfar  = 30.0f;
    xmax  = znear * 0.5f;
    
    glViewport( 0, 0, (GLint) width, (GLint) height );
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    glFrustum( -xmax, xmax, -xmax*h, xmax*h, znear, zfar );
}


/* program & OpenGL initialization */
static void init(int argc, char *argv[])
{
    GLint i;
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_NORMALIZE);
    
    for ( i=1; i<argc; i++ ) {
        if (strcmp(argv[i], "-info")==0) {
            printf("GL_RENDERER   = %s\n", (char *) glGetString(GL_RENDERER));
            printf("GL_VERSION    = %s\n", (char *) glGetString(GL_VERSION));
            printf("GL_VENDOR     = %s\n", (char *) glGetString(GL_VENDOR));
            printf("GL_EXTENSIONS = %s\n", (char *) glGetString(GL_EXTENSIONS));
        }
    }
}


/* program entry */
int main(int argc, char *argv[])
{
    GLFWwindow* window;
    int width, height;
    
    if( !glfwInit() )
    {
        fprintf( stderr, "Failed to initialize GLFW\n" );
        exit( EXIT_FAILURE );
    }
    
    glfwWindowHint(GLFW_DEPTH_BITS, 16);
    
    int monitorCount;
    
    GLFWmonitor *primMonitor = glfwGetPrimaryMonitor();
    GLFWvidmode const * vidModes = glfwGetVideoModes(primMonitor, &monitorCount);
    GLFWvidmode const & vidMode = vidModes[monitorCount-1];
    
    window = glfwCreateWindow( vidMode.width, vidMode.height, "Gears", primMonitor, NULL );
    if (!window)
    {
        fprintf( stderr, "Failed to open GLFW window\n" );
        glfwTerminate();
        exit( EXIT_FAILURE );
    }
    
    
    // Set callback functions
    glfwSetFramebufferSizeCallback(window, reshape);
    glfwSetKeyCallback(window, key);
    
    glfwMakeContextCurrent(window);
    glfwSwapInterval( 1 );
    
    player = glm::translate(mat4(1), vec3(0,0,20));
    
    glfwGetFramebufferSize(window, &width, &height);
    reshape(window, width, height);
    
    // Parse command-line options
    init(argc, argv);
    
    // Main loop
    while( !glfwWindowShouldClose(window) )
    {
        // Draw gears
        draw();
        
        // Update animation
        animate();
        
        // Swap buffers
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // Terminate GLFW
    glfwTerminate();
    
    // Exit program
    exit( EXIT_SUCCESS );
}
