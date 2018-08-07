import PlaygroundSupport
import MetalKit

// Make sure get a device first
//
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

// Create a MTKView
//
let frame = NSRect(origin: CGPoint.zero, size: CGSize(width: 600, height: 600))
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColorMake(1, 1, 0.8, 1.0)

// Create a command queue
//
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

// Loading a model
//
// 1. An allocator that manage the memory for the mesh data
//
let allocator = MTKMeshBufferAllocator(device: device)
//
// 2. Create a sphere with given size from Model I/O
//
let mdlMesh = MDLMesh(sphereWithExtent: [0.5,0.5,0.5], segments: [100,100], inwardNormals: false, geometryType:.triangles, allocator: allocator)
//
// 3. Convert the mdlMesh into a Metal mesh
//
guard let mesh = try? MTKMesh(mesh: mdlMesh, device: device) else {
    fatalError("Load model error")
}

// Prepare shaders
//
guard let filePath = Bundle.main.path(forResource: "Shaders", ofType: "metal") else {
    fatalError("Could not load Metal shader file")
}

guard let source = try? String(contentsOf: URL(fileURLWithPath: filePath)) else {
    fatalError("Could not load Metal shader source")
}

guard let library = try? device.makeLibrary(source: source, options: nil) else {
    fatalError("Create Metal library error")
}
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

// Create a pipeline state via a descriptor
//
let descriptor = MTLRenderPipelineDescriptor()
descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//
// Shader
//
descriptor.vertexFunction = vertexFunction
descriptor.fragmentFunction = fragmentFunction
//
// Model
//
descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

// Pipeline state
//
guard let pipelineState = try? device.makeRenderPipelineState(descriptor: descriptor) else {
    fatalError("Create pipeline failed")
}

// Rendering
//
guard
    // 1. Command buffer for storing the commands
    //
    let commandBuffer = commandQueue.makeCommandBuffer(),
    //
    // 2. Get a render pass descriptor
    //
    let rpd = view.currentRenderPassDescriptor,
    //
    // 3. An encoder for encoding the command to GPU
    //
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) else {
        fatalError("Render process error")
}

// Encoding
//
renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

// A mesh is make up of submeshes, we only have one submesh in a sphere
//
guard let submesh = mesh.submeshes.first else {
    fatalError("Invalid mesh data")
}

renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer:submesh.indexBuffer.buffer, indexBufferOffset: 0)

renderEncoder.endEncoding()

// Drawing
//
// A drawable texture that Metal can write and read to
//
guard let drawable = view.currentDrawable else {
    fatalError("Could not drawable")
}

commandBuffer.present(drawable)
commandBuffer.commit()

// Playground
//
PlaygroundPage.current.liveView = view
