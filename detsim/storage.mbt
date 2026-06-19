/// 确定性模拟文件系统，纯内存操作，无真实 I/O。

pub struct SimStorage {
  files : Map[String, Bytes]
}

/// 创建空的模拟存储。
pub fn SimStorage::new() -> SimStorage {
  SimStorage::{ files: Map([], capacity=16) }
}

/// 读取文件内容。
pub fn SimStorage::read(
  self : SimStorage,
  path : String,
) -> Result[Bytes, String] {
  match self.files.get(path) {
    Some(data) => Ok(data)
    None => Err("文件未找到: \{path}")
  }
}

/// 写入文件（创建或覆盖）。
pub fn SimStorage::write(
  self : SimStorage,
  path : String,
  data : Bytes,
) -> SimStorage {
  let files = self.files
  files.set(path, data)
  SimStorage::{ files }
}

/// 删除文件。
pub fn SimStorage::delete(
  self : SimStorage,
  path : String,
) -> Result[SimStorage, String] {
  if self.files.contains(path) {
    let files = self.files
    files.remove(path)
    Ok(SimStorage::{ files })
  } else {
    Err("文件未找到: \{path}")
  }
}

/// 检查文件是否存在。
pub fn SimStorage::exists(self : SimStorage, path : String) -> Bool {
  self.files.contains(path)
}

/// 获取已存储文件数量。
pub fn SimStorage::file_count(self : SimStorage) -> Int {
  self.files.length()
}
