package com.orm.himedia.project_phonebook.Controller;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap; // Map을 생성하기 위해 필요
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType; // MediaType 임포트 추가
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping; // PATCH 메서드 추가 (즐겨찾기 업데이트용)
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.orm.himedia.project_phonebook.DAO.ContactDAO;
import com.orm.himedia.project_phonebook.DTO.ContactDTO;

import jakarta.annotation.PostConstruct;

@RestController
@RequestMapping("/api/contacts")
@CrossOrigin(origins = "*") 
public class ContactController {
	public static final String USER_HOME = System.getProperty("user.home");
	public static final String UPLOAD_DIR_PATH = Paths.get(USER_HOME, "uploads").toString(); 

	@Configuration
	public static class WebConfig implements WebMvcConfigurer {
		@Override
		public void addResourceHandlers(ResourceHandlerRegistry registry) {
		    registry
		        .addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + UPLOAD_DIR_PATH + "/");
		    }
	}
	
	 @Autowired
	 private ContactDAO dao;

	 @PostConstruct
	    public void init() {
	        Path uploadPath = Paths.get(UPLOAD_DIR_PATH);
	        if (!Files.exists(uploadPath)) {
	            try {
	                Files.createDirectories(uploadPath);
	                System.out.println("Upload directory created: " + uploadPath.toAbsolutePath());
	            } catch (IOException e) {
	                System.err.println("Failed to create upload directory at " + uploadPath.toAbsolutePath() + ": " + e.getMessage());
	            }
	        }
	    }


    @GetMapping
    public ResponseEntity<List<ContactDTO>> getAll() {
    	System.out.println("--- getAllContacts ---");
        List<ContactDTO> contacts = dao.getAllContacts();
        System.out.println("Fetched contacts: " + contacts.size());
        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContactDTO> getOne(@PathVariable("id") int id) {
    	System.out.println("--- getContactById ---");
        ContactDTO contact = dao.getContactById(id);
        System.out.println("Contact found: " + contact);
        if (contact != null) {
            return new ResponseEntity<>(contact, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping
    public ResponseEntity<ContactDTO> create(@RequestBody ContactDTO contact) {
    	System.out.println("--- createContact ---");
        dao.insertContact(contact); 
        return new ResponseEntity<>(contact, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ContactDTO> update(@PathVariable("id") int id, @RequestBody ContactDTO contact) {
    	System.out.println("--- updateContact ---");
    	System.out.println("Received contact for update: " + contact);
        contact.setId(id);
        dao.updateContact(contact);
        ContactDTO updatedContact = dao.getContactById(id);
        if (updatedContact != null) {
            return new ResponseEntity<>(updatedContact, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    
    @PutMapping("/{id}/favorite")
    public ResponseEntity<ContactDTO> updateFavoriteStatus(@PathVariable("id") int contactId, @RequestBody Map<String, Object> requestBody) {
        System.out.println("--- updateFavoriteStatus (PUT) ---");
        Object favoriteObj = requestBody.get("favorite");
        if (favoriteObj == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        boolean favorite;
        if (favoriteObj instanceof Boolean) {
            favorite = (Boolean) favoriteObj;
        } else if (favoriteObj instanceof String) {
            favorite = Boolean.parseBoolean((String) favoriteObj);
        } else if (favoriteObj instanceof Integer) {
            favorite = ((Integer) favoriteObj) == 1;
        } else {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        dao.updateFavoriteStatus(contactId, favorite);
        ContactDTO updatedContact = dao.getContactById(contactId);
        if (updatedContact != null) {
            return new ResponseEntity<>(updatedContact, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") int id) {
        dao.deleteContact(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<ContactDTO>> search(@RequestParam(value = "input", required = false, defaultValue = "") String input) {
    	System.out.println("🔍 검색 요청 - keyword: " + input);
        List<ContactDTO> searchResults = dao.search(input, input, input, input, input); // 이 부분은 DAO에 맞게 조정 필요
        System.out.println("검색 결과: " + searchResults.size() + "개");
        return new ResponseEntity<>(searchResults, HttpStatus.OK);
    }
    
    @GetMapping("/favorites")
    public ResponseEntity<List<ContactDTO>> getFavoriteContacts() {
    	System.out.println("--- getFavoriteContacts ---");
        List<ContactDTO> favorites = dao.getFavoriteContacts();
        return new ResponseEntity<>(favorites, HttpStatus.OK);
    }

    @GetMapping("/groups")
    public ResponseEntity<List<Map<String, Object>>> getAllGroups() {
    	System.out.println("--- getAllGroups ---");
        List<Map<String, Object>> groups = dao.getAllGroupsWithMemberCount();
        return new ResponseEntity<>(groups, HttpStatus.OK);
    }

    @PostMapping("/groups")
    public ResponseEntity<Void> createGroup(@RequestBody Map<String, String> requestBody) {
        String groupName = requestBody.get("name");
        if (groupName == null || groupName.trim().isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        dao.createGroup(groupName);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @PutMapping("/groups")
    public ResponseEntity<Void> renameGroup(@RequestParam("oldName") String oldGroupName, @RequestParam("newName") String newGroupName) {
        if (oldGroupName == null || oldGroupName.trim().isEmpty() || newGroupName == null || newGroupName.trim().isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        dao.renameGroup(oldGroupName, newGroupName);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @DeleteMapping("/groups/{groupName}")
    public ResponseEntity<Void> deleteGroup(@PathVariable("groupName") String groupName) {
        if (groupName == null || groupName.trim().isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        dao.deleteGroup(groupName);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @PostMapping("/api/contacts/batch-delete")
//    public ResponseEntity<Map<String, String>> deleteContacts(@RequestBody List<Integer> requestBody) {
    public ResponseEntity<Void> deleteContacts(@RequestBody List<Integer> ids) {
    	   dao.deleteContactsByIds(ids);
    	   return ResponseEntity.noContent().build();
//    	List<Integer> idsToDelete = requestBody.get("ids");
//    	System.out.println("--- batch-delete --- IDs: " + idsToDelete);
//    	if (idsToDelete == null || idsToDelete.isEmpty()) {
//    	    return ResponseEntity.badRequest().body(Map.of("message", "삭제할 연락처 ID가 제공되지 않았습니다."));
//    	}
//
//        int deletedCount = dao.deleteContactsByIds(idsToDelete);
//
//        if (deletedCount > 0) {
//            return ResponseEntity.ok(Map.of("message", deletedCount + "개의 연락처가 성공적으로 삭제되었습니다."));
//        } else {
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "삭제할 연락처를 찾을 수 없거나 이미 삭제되었습니다."));
//        }
    }
    
    @GetMapping("/all-contacts-for-group-assignment")
    public ResponseEntity<List<ContactDTO>> getAllContactsForGroupAssignment() {
        List<ContactDTO> contacts = dao.getAllContactsForGroupAssignment();
        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    @GetMapping("/groups/{groupName}/contacts")
    public ResponseEntity<List<ContactDTO>> getContactsByGroup(
            @PathVariable("groupName") String groupName,
            @RequestParam(value = "sortBy", defaultValue = "name", required = false) String sortBy,
            @RequestParam(value = "sortOrder", defaultValue = "asc", required = false) String sortOrder) {
        List<ContactDTO> contacts = dao.getContactsByGroup(groupName, sortBy, sortOrder);
        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    @PutMapping("/{id}/group")
    public ResponseEntity<Void> updateContactGroup(@PathVariable("id") int id, @RequestBody Map<String, String> requestBody) {
        String group = requestBody.get("group");
        if ("null".equalsIgnoreCase(group) || (group != null && group.trim().isEmpty())) {
            group = null;
        }
        dao.updateContactGroup(id, group);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/uploads")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("image") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "업로드할 파일이 없습니다."));
        }

        try {
            String originalFileName = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFileName != null && originalFileName.contains(".")) {
                fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
            }
            
            String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
            
            Path uploadPath = Paths.get(UPLOAD_DIR_PATH);
            Files.createDirectories(uploadPath);

            Path filePath = uploadPath.resolve(uniqueFileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            System.out.println("File uploaded to: " + filePath.toAbsolutePath());

            String imageUrl = "/uploads/" + uniqueFileName;
            
            Map<String, String> response = new HashMap<>();
            response.put("url", imageUrl);
            response.put("message", "이미지 업로드 성공");
            return ResponseEntity.ok(response);

        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                 .body(Map.of("message", "파일 업로드 중 오류 발생: " + e.getMessage()));
        }
    }

    @GetMapping("/uploads/{filename:.+}")
    public ResponseEntity<Resource> serveImage(@PathVariable(value="filename") String filename) {
        try {
            Path filePath = Paths.get(UPLOAD_DIR_PATH).resolve(filename).normalize(); // UPLOAD_DIR_PATH 사용
            Resource resource = new UrlResource(filePath.toUri());
            
            if (resource.exists() && resource.isReadable()) {
                String contentType = null;
                try {
                    contentType = Files.probeContentType(filePath);
                } catch (IOException e) {
                    System.err.println("Failed to probe content type for " + filename + ": " + e.getMessage());
                }
                if (contentType == null) {
                    contentType = "application/octet-stream";
                }

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (MalformedURLException e) {
            System.err.println("MalformedURLException when serving file: " + filename + " - " + e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/{id}/toggleFavorite")
    public ResponseEntity<ContactDTO> toggleFavoriteStatus(@PathVariable("id") Integer id,  @RequestBody Map<String, Boolean> favorite) {
    	System.out.println("테스트001");
    	try {
            Boolean favoriteStatus = favorite.get("favorite");

            if (favoriteStatus == null) {
                System.err.println("Error: 'favorite' field is missing or null in request body.");
                return new ResponseEntity<>(HttpStatus.BAD_REQUEST); 
            }

            int rowsAffected = dao.updateContactFavorite(id, favoriteStatus);
            
            if (rowsAffected == 0) {
                System.err.println("Error: Contact with ID " + id + " not found or could not be updated.");
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }

            ContactDTO updatedContact = dao.getContactById(id);
            return new ResponseEntity<>(updatedContact, HttpStatus.OK);
            
        } catch (IllegalArgumentException e) {
            System.err.println("Error: " + e.getMessage());
            return new ResponseEntity<>(HttpStatus.NOT_FOUND); 
        } catch (Exception e) {
            System.err.println("Internal Server Error: " + e.getMessage());
            e.printStackTrace(); 
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    
}