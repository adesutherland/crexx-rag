#pragma once

#include <string>
#include <vector>

namespace cprag {

enum class ChunkFileType {
    PlainText = 0,
    CodeRexx = 3,
    Markdown = 7
};

std::vector<std::string> chunkText(
    const std::string& text,
    int chunkSize,
    int chunkOverlap,
    ChunkFileType fileType);

} // namespace cprag

