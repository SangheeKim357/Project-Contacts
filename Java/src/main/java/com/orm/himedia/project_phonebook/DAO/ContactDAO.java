package com.orm.himedia.project_phonebook.DAO;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.orm.himedia.project_phonebook.DTO.ContactDTO;

@Mapper
public interface ContactDAO {
    List<ContactDTO> getAllContacts();
    ContactDTO getContactById(int id);
    void insertContact(ContactDTO contact);
    void updateContact(ContactDTO contact);
    void deleteContact(int id);
    
//    List<ContactDTO> search(
//    	    @Param("name") String name,
//    	    @Param("phone") String phone,
//    	    @Param("home") String home,
//    	    @Param("company") String company);    

	// 즐겨찾기 기능
	List<ContactDTO> getFavoriteContacts();

	void updateFavoriteStatus(@Param("contactId") int id, @Param("favorite") boolean favorite); // 'id' 대신 'contactId'로
																								// 변경

	// 그룹 관리 기능 (contacts 테이블의 'group' 필드만 사용)
	List<Map<String, Object>> getAllGroupsWithMemberCount();

	void createGroup(@Param("name") String name);

	void renameGroup(@Param("oldGroupName") String oldGroupName, @Param("newGroupName") String newGroupName);

	void deleteGroup(@Param("groupName") String groupName);

	void updateContactGroup(@Param("id") int id, @Param("group") String group);

	int deleteContactsByIds(@Param("ids") List<Integer> ids);
	
	List<ContactDTO> getContactsByGroup(@Param("groupName") String groupName, @Param("sortBy") String sortBy,
			@Param("sortOrder") String sortOrder);

	List<ContactDTO> getAllContactsForGroupAssignment();
	List<ContactDTO> search(@Param("name") String name,
    	    @Param("phone") String phone,
    	    @Param("home") String home,
    	    @Param("company") String company,
    	    @Param("memo") String memo);
	
    int updateContactFavorite(@Param("id") Integer id, @Param("favorite") Boolean favorite);
    ContactDTO getContactById(Integer id);

}